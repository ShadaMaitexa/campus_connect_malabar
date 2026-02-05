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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Overview"),
    const SidebarDestination(icon: Icons.work_rounded, label: "Jobs & Materials"),
    const SidebarDestination(icon: Icons.event_rounded, label: "Events"),
    const SidebarDestination(icon: Icons.campaign_rounded, label: "Notices"),
    const SidebarDestination(icon: Icons.verified_user_rounded, label: "Approvals"),
    const SidebarDestination(icon: Icons.manage_accounts_rounded, label: "Users"),
    const SidebarDestination(icon: Icons.library_books_rounded, label: "Library"),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Row(
        children: [
          PremiumSidebar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _handleGlobalNavigation(index);
            },
            destinations: _destinations,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildDesktopAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Library Management",
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        _buildLibraryStatsRow(),
                        const SizedBox(height: 48),
                        const SectionHeader(title: "Library Operations"),
                        const SizedBox(height: 24),
                        _buildLibraryOpsGrid(isDesktop: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text("Library Admin"),
        actions: [
          IconButton(onPressed: _loadLibraryStats, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMobileHeader(),
                const SizedBox(height: 24),
                _buildLibraryStatsGrid(),
                const SizedBox(height: 32),
                const SectionHeader(title: "Management"),
                const SizedBox(height: 16),
                _buildLibraryOpsGrid(isDesktop: false),
              ],
            ),
          ),
    );
  }

  Widget _buildDesktopAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text("Back to Admin"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkSurface,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.library_books_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          Text("System Pulse", style: GoogleFonts.inter(color: Colors.white70)),
          Text("Inventory Overview", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLibraryStatsRow() {
    return Row(
      children: [
        Expanded(child: PremiumStatCard(title: "Collection", value: "$_totalBooks", icon: Icons.book_rounded, gradient: AppGradients.primary)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Active Issues", value: "$_issuedBooks", icon: Icons.outbound_rounded, gradient: AppGradients.accent)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Pending Returns", value: "$_pendingReturns", icon: Icons.assignment_return_rounded, gradient: AppGradients.success)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Total Revenue", value: "₹${_totalFines.toStringAsFixed(0)}", icon: Icons.payments_rounded, gradient: AppGradients.surface)),
      ],
    );
  }

  Widget _buildLibraryStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _miniStat(Icons.book, "$_totalBooks", "Books", AppGradients.primary),
        _miniStat(Icons.outbound, "$_issuedBooks", "Issued", AppGradients.accent),
        _miniStat(Icons.assignment_return, "$_pendingReturns", "Pending", AppGradients.success),
        _miniStat(Icons.payments, "₹${_totalFines.toInt()}", "Fines", AppGradients.surface),
      ],
    );
  }

  Widget _miniStat(IconData icon, String value, String label, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLibraryOpsGrid({required bool isDesktop}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _opCard("Manage Books", Icons.menu_book_rounded, AppGradients.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBooks()))),
        _opCard("Return Approval", Icons.fact_check_rounded, AppGradients.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnApproval()))),
        _opCard("Fine Tracking", Icons.account_balance_wallet_rounded, AppGradients.accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinePaymentsScreen()))),
        _opCard("Issue History", Icons.history_rounded, AppGradients.surface, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueHistory()))),
      ],
    );
  }

  Widget _opCard(String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return DashboardCard(
      title: title,
      value: "View",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }

  void _handleGlobalNavigation(int index) {
     if (index == 6) return; // Already here
     Navigator.pop(context); // Go back to admin dashboard
  }
}
