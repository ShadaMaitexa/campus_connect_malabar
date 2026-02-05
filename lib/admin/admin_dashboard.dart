import 'package:campus_connect_malabar/admin/admin_users.dart';
import 'package:campus_connect_malabar/admin/post_event.dart';
import 'package:campus_connect_malabar/admin/post_global_notice.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final pendingSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('approved', isEqualTo: false)
          .get();
      final jobsSnap = await FirebaseFirestore.instance.collection('jobs').get();
      final eventsSnap = await FirebaseFirestore.instance.collection('events').get();

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
              setState(() => _selectedIndex = index);
              _navigateToDestination(index);
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
                        Text(
                          "Welcome back, Admin",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Here's what's happening across the campus today.",
                          style: GoogleFonts.inter(color: AppTheme.darkTextSecondary),
                        ),
                        const SizedBox(height: 48),
                        _buildStatsRow(),
                        const SizedBox(height: 48),
                        const SectionHeader(title: "Management Actions"),
                        const SizedBox(height: 24),
                        _buildManagementGrid(isDesktop: true),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildMobileHeader()),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SectionHeader(title: 'Overview'),
                  const SizedBox(height: 16),
                  _isLoading ? const Center(child: CircularProgressIndicator()) : _buildStatsGrid(),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Management'),
                  const SizedBox(height: 16),
                  _buildManagementGrid(isDesktop: false),
                ],
              ),
            ),
          ),
        ],
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor.withOpacity(0.1), foregroundColor: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Admin Panel", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Control Center • Super Admin", style: GoogleFonts.inter(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: PremiumStatCard(title: "Total Users", value: "$_totalUsers", icon: Icons.people_rounded, gradient: AppGradients.primary)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Pending Approvals", value: "$_pendingApprovals", icon: Icons.verified_user_rounded, gradient: AppGradients.success, trend: "4 New", isPositive: false)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Active Jobs", value: "$_totalJobs", icon: Icons.work_rounded, gradient: AppGradients.accent)),
        const SizedBox(width: 24),
        Expanded(child: PremiumStatCard(title: "Total Events", value: "$_totalEvents", icon: Icons.event_rounded, gradient: AppGradients.surface)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(Icons.people_rounded, "$_totalUsers", "Users", AppGradients.primary),
        _buildStatCard(Icons.verified_user_rounded, "$_pendingApprovals", "Pending", AppGradients.success),
        _buildStatCard(Icons.work_rounded, "$_totalJobs", "Jobs", AppGradients.accent),
        _buildStatCard(Icons.event_rounded, "$_totalEvents", "Events", AppGradients.surface),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20), boxShadow: AppEffects.subtleShadow),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildManagementGrid({required bool isDesktop}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _actionCard("Jobs & Materials", Icons.work_rounded, AppGradients.accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminJobs()))),
        _actionCard("Events", Icons.event_rounded, AppGradients.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminViewEvents()))),
        _actionCard("Notices", Icons.campaign_rounded, AppGradients.surface, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotices()))),
        _actionCard("Approvals", Icons.verified_user_rounded, AppGradients.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveUsers()))),
        _actionCard("Manage Users", Icons.manage_accounts_rounded, AppGradients.danger, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsers()))),
        _actionCard("Library", Icons.library_books_rounded, AppGradients.surface, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLibrary()))),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return DashboardCard(
      title: title,
      value: "Manage",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }

  void _navigateToDestination(int index) {
    // Shared navigation logic
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }
}
