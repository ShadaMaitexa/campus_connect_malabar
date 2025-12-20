import 'package:campus_connect_malabar/admin/admin_users.dart';
import 'package:campus_connect_malabar/admin/post_event.dart';
import 'package:campus_connect_malabar/admin/post_global_notice.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';
import 'admin_jobs.dart';
import 'approve_users.dart';
import 'admin_library.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalUsers = 0;
  int _pendingApprovals = 0;
  int _totalJobs = 0;
  int _totalEvents = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Load total users
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      
      // Load pending approvals
      final pendingSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('approved', isEqualTo: false)
          .get();

      // Load total jobs
      final jobsSnap =
          await FirebaseFirestore.instance.collection('jobs').get();

      // Load total events
      final eventsSnap =
          await FirebaseFirestore.instance.collection('events').get();

      if (mounted) {
        setState(() {
          _totalUsers = usersSnap.docs.length;
          _pendingApprovals = pendingSnap.docs.length;
          _totalJobs = jobsSnap.docs.length;
          _totalEvents = eventsSnap.docs.length;
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
                child: const SectionHeader(title: 'Overview'),
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
        gradient: AppGradients.secondary,
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
                          'Admin Panel',
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
                                Icons.admin_panel_settings_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Super Admin',
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
                  icon: Icons.people_rounded,
                  value: '$_totalUsers',
                  label: 'Total Users',
                  gradient: AppGradients.blue,
                ),
              ),
              const SizedBox(height: 12),
              AppAnimations.slideInFromLeft(
                delay: const Duration(milliseconds: 300),
                child: _buildStatCard(
                  icon: Icons.work_rounded,
                  value: '$_totalJobs',
                  label: 'Jobs Posted',
                  gradient: AppGradients.info,
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
                  icon: Icons.pending_actions_rounded,
                  value: '$_pendingApprovals',
                  label: 'Pending',
                  gradient: _pendingApprovals > 0
                      ? AppGradients.warning
                      : AppGradients.green,
                ),
              ),
              const SizedBox(height: 12),
              AppAnimations.slideInFromRight(
                delay: const Duration(milliseconds: 300),
                child: _buildStatCard(
                  icon: Icons.event_rounded,
                  value: '$_totalEvents',
                  label: 'Events',
                  gradient: AppGradients.purple,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
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
              title: "Jobs & Materials",
              value: "Manage",
              icon: Icons.work_rounded,
              gradient: AppGradients.info,
              showArrow: true,
              index: 0,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const AdminJobs()),
              ),
            ),
            DashboardCard(
              title: "Events",
              value: "Manage",
              icon: Icons.event_rounded,
              gradient: AppGradients.purple,
              showArrow: true,
              index: 1,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const AdminViewEvents()),
              ),
            ),
            DashboardCard(
              title: "Global Notices",
              value: "Broadcast",
              icon: Icons.campaign_rounded,
              gradient: AppGradients.orange,
              showArrow: true,
              index: 2,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const AdminNotices()),
              ),
            ),
            DashboardCard(
              title: "Approve Users",
              value: _pendingApprovals > 0 ? "$_pendingApprovals Pending" : "All Clear",
              icon: Icons.verified_user_rounded,
              gradient: _pendingApprovals > 0
                  ? AppGradients.warning
                  : AppGradients.green,
              showArrow: true,
              index: 3,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const ApproveUsers()),
              ),
            ),
            DashboardCard(
              title: "Manage Users",
              value: "Block/Unblock",
              icon: Icons.manage_accounts_rounded,
              gradient: AppGradients.red,
              showArrow: true,
              index: 4,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const AdminUsers()),
              ),
            ),
            DashboardCard(
              title: "Library",
              value: "Manage",
              icon: Icons.library_books_rounded,
              gradient: AppGradients.dark,
              showArrow: true,
              index: 5,
              onTap: () => Navigator.push(
                context,
                PageTransitions.slideUp(page: const AdminLibrary()),
              ),
            ),
          ],
        );
      },
    );
  }
}
