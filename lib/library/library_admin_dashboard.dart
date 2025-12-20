import 'package:campus_connect_malabar/auth/login_screen.dart';
import 'package:campus_connect_malabar/library/fine_payment_screen.dart';
import 'package:campus_connect_malabar/library/issue_history.dart';
import 'package:campus_connect_malabar/library/issued_book_screen.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_books.dart';
import 'library_analytics_screen.dart';

class LibraryAdminDashboard extends StatefulWidget {
  const LibraryAdminDashboard({super.key});

  @override
  State<LibraryAdminDashboard> createState() => _LibraryAdminDashboardState();
}

class _LibraryAdminDashboardState extends State<LibraryAdminDashboard> {
  int _totalBooks = 0;
  int _issuedBooks = 0;
  int _pendingReturns = 0;
  int _totalFines = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Load total books
      final booksSnap =
          await FirebaseFirestore.instance.collection('books').get();

      // Load issued books
      final issuedSnap = await FirebaseFirestore.instance
          .collection('issued_books')
          .where('returned', isEqualTo: false)
          .get();

      // Load pending returns (overdue)
      final now = DateTime.now();
      int pendingCount = 0;
      int totalFine = 0;

      for (var doc in issuedSnap.docs) {
        final dueDate = (doc.data()['dueDate'] as Timestamp).toDate();
        if (dueDate.isBefore(now)) {
          pendingCount++;
          final daysOverdue = now.difference(dueDate).inDays;
          totalFine += daysOverdue * 5; // ₹5 per day fine
        }
      }

      if (mounted) {
        setState(() {
          _totalBooks = booksSnap.docs.length;
          _issuedBooks = issuedSnap.docs.length;
          _pendingReturns = pendingCount;
          _totalFines = totalFine;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Header
          SliverToBoxAdapter(
            child: _buildHeader(context, isDark),
          ),

          // Stats Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: AppAnimations.slideInFromBottom(
                delay: const Duration(milliseconds: 100),
                child: const SectionHeader(title: 'Library Stats'),
              ),
            ),
          ),

          // Stats Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _isLoading
                  ? const ShimmerGrid(
                      itemCount: 4,
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                    )
                  : _buildStatsGrid(),
            ),
          ),

          // Management Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: AppAnimations.slideInFromBottom(
                delay: const Duration(milliseconds: 300),
                child: const SectionHeader(title: 'Management'),
              ),
            ),
          ),

          // Management Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverToBoxAdapter(
              child: _buildManagementGrid(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.dark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppAnimations.slideInFromLeft(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Library Admin',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Control Center',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.library_books_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Librarian',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppAnimations.scaleIn(
                    child: _buildLogoutButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.logout_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              AppAnimations.slideInFromLeft(
                delay: const Duration(milliseconds: 200),
                child: _buildStatCard(
                  icon: Icons.menu_book_rounded,
                  value: '$_totalBooks',
                  label: 'Total Books',
                  gradient: AppGradients.blue,
                ),
              ),
              const SizedBox(height: 12),
              AppAnimations.slideInFromLeft(
                delay: const Duration(milliseconds: 300),
                child: _buildStatCard(
                  icon: Icons.book_rounded,
                  value: '$_issuedBooks',
                  label: 'Issued',
                  gradient: AppGradients.purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              AppAnimations.slideInFromRight(
                delay: const Duration(milliseconds: 200),
                child: _buildStatCard(
                  icon: Icons.assignment_late_rounded,
                  value: '$_pendingReturns',
                  label: 'Overdue',
                  gradient: _pendingReturns > 0
                      ? AppGradients.warning
                      : AppGradients.green,
                ),
              ),
              const SizedBox(height: 12),
              AppAnimations.slideInFromRight(
                delay: const Duration(milliseconds: 300),
                child: _buildStatCard(
                  icon: Icons.currency_rupee_rounded,
                  value: '₹$_totalFines',
                  label: 'Fines Due',
                  gradient: _totalFines > 0
                      ? AppGradients.red
                      : AppGradients.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            DashboardCard(
              title: "Manage Books",
              value: "Add/Edit",
              icon: Icons.library_add_rounded,
              gradient: AppGradients.blue,
              showArrow: true,
              index: 0,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const ManageBooks()),
              ),
            ),
            DashboardCard(
              title: "Return Approval",
              value: "Process",
              icon: Icons.assignment_turned_in_rounded,
              gradient: AppGradients.green,
              showArrow: true,
              index: 1,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const IssuedBookScreen()),
              ),
            ),
            DashboardCard(
              title: "Fine Payments",
              value: _totalFines > 0 ? "₹$_totalFines Due" : "Clear",
              icon: Icons.payments_rounded,
              gradient: _totalFines > 0 ? AppGradients.orange : AppGradients.teal,
              showArrow: true,
              index: 2,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const FinePaymentsScreen()),
              ),
            ),
            DashboardCard(
              title: "Analytics",
              value: "Reports",
              icon: Icons.bar_chart_rounded,
              gradient: AppGradients.purple,
              showArrow: true,
              index: 3,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const LibraryAnalyticsScreen()),
              ),
            ),
            DashboardCard(
              title: "Issue History",
              value: "Records",
              icon: Icons.history_rounded,
              gradient: AppGradients.grey,
              showArrow: true,
              index: 4,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const IssueHistoryScreen()),
              ),
            ),
          ],
        );
      },
    );
  }
}
