import 'package:campus_connect_malabar/admin/admin_users.dart';
import 'package:campus_connect_malabar/admin/post_event.dart';
import 'package:campus_connect_malabar/admin/post_global_notice.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
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
  int _selectedIndex = 0;

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Overview"),
    const SidebarDestination(
      icon: Icons.work_rounded,
      label: "Jobs & Materials",
    ),
    const SidebarDestination(icon: Icons.event_rounded, label: "Events"),
    const SidebarDestination(icon: Icons.campaign_rounded, label: "Notices"),
    const SidebarDestination(
      icon: Icons.verified_user_rounded,
      label: "Approvals",
    ),
    const SidebarDestination(
      icon: Icons.manage_accounts_rounded,
      label: "Users",
    ),
    const SidebarDestination(
      icon: Icons.library_books_rounded,
      label: "Library",
    ),
    const SidebarDestination(icon: Icons.logout_rounded, label: "Logout"),
  ];

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return AdminOverview(
          onNavigate: (index) {
            setState(() => _selectedIndex = index);
          },
          onLogout: () => _handleLogout(),
        );
      case 1:
        return const AdminJobs();
      case 2:
        return const AdminViewEvents();
      case 3:
        return const AdminNotices();
      case 4:
        return const ApproveUsers();
      case 5:
        return const AdminUsers();
      case 6:
        return const AdminLibrary();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
  }

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
      body: Stack(
        children: [
          // Global Premium Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/generated_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: AppTheme.darkBackground.withOpacity(0.9)),
          ),
          Row(
            children: [
              PremiumSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  if (index == 7) {
                    _handleLogout();
                  } else {
                    setState(() => _selectedIndex = index);
                  }
                },
                destinations: _destinations,
                onLogout: _handleLogout,
                userName: "Admin User",
                userRole: "Super Admin",
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _getScreen(_selectedIndex),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _destinations[_selectedIndex].label,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        backgroundColor: AppTheme.darkSurface,
        child: PremiumSidebar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 7) {
              Navigator.pop(context);
              _handleLogout();
            } else {
              setState(() => _selectedIndex = index);
              Navigator.pop(context); // Close drawer
            }
          },
          destinations: _destinations,
          userName: "Admin User",
          userRole: "Super Admin",
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/generated_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: AppTheme.darkBackground.withOpacity(0.92)),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _getScreen(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
    }
  }
}

class AdminOverview extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;
  const AdminOverview({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
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
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final pendingSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('approved', isEqualTo: false)
          .get();
      final marketplaceSnap = await FirebaseFirestore.instance
          .collection('marketplace')
          .get();
      final eventsSnap = await FirebaseFirestore.instance
          .collection('events')
          .get();

      if (mounted) {
        setState(() {
          _totalUsers = usersSnap.docs.length;
          _pendingApprovals = pendingSnap.docs.length;
          _totalJobs = marketplaceSnap.docs.length;
          _totalEvents = eventsSnap.docs.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          if (isDesktop) _buildDesktopAppBar(),
          SliverPadding(
            padding: EdgeInsets.all(isDesktop ? 40 : 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop) _buildMobileHeader(),
                  const SizedBox(height: 24),
                  Text(
                    "Overview",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Welcome back, Admin",
                    style: GoogleFonts.outfit(
                      fontSize: isDesktop ? 40 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Real-time visibility into your campus ecosystem.",
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(100),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : isDesktop
                      ? _buildStatsRow()
                      : _buildStatsGrid(),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const SectionHeader(title: "Management Hub"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildManagementGrid(isDesktop: isDesktop),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  "Search metrics...",
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: "Logout",
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Panel",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Control Center • Super Admin",
            style: GoogleFonts.inter(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => widget.onNavigate(5),
            borderRadius: BorderRadius.circular(20),
            child: PremiumStatCard(
              title: "Total Users",
              value: "$_totalUsers",
              icon: Icons.people_rounded,
              gradient: AppGradients.primary,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: InkWell(
            onTap: () => widget.onNavigate(4),
            borderRadius: BorderRadius.circular(20),
            child: PremiumStatCard(
              title: "Pending Approvals",
              value: "$_pendingApprovals",
              icon: Icons.verified_user_rounded,
              gradient: AppGradients.success,
              trend: "4 New",
              isPositive: false,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: InkWell(
            onTap: () => widget.onNavigate(1),
            borderRadius: BorderRadius.circular(20),
            child: PremiumStatCard(
              title: "Active Jobs",
              value: "$_totalJobs",
              icon: Icons.work_rounded,
              gradient: AppGradients.accent,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: InkWell(
            onTap: () => widget.onNavigate(2),
            borderRadius: BorderRadius.circular(20),
            child: PremiumStatCard(
              title: "Total Events",
              value: "$_totalEvents",
              icon: Icons.event_rounded,
              gradient: AppGradients.surface,
            ),
          ),
        ),
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
        InkWell(
          onTap: () => widget.onNavigate(5),
          child: _buildStatCard(
            Icons.people_rounded,
            "$_totalUsers",
            "Users",
            AppGradients.primary,
          ),
        ),
        InkWell(
          onTap: () => widget.onNavigate(4),
          child: _buildStatCard(
            Icons.verified_user_rounded,
            "$_pendingApprovals",
            "Pending",
            AppGradients.success,
          ),
        ),
        InkWell(
          onTap: () => widget.onNavigate(1),
          child: _buildStatCard(
            Icons.work_rounded,
            "$_totalJobs",
            "Jobs",
            AppGradients.accent,
          ),
        ),
        InkWell(
          onTap: () => widget.onNavigate(2),
          child: _buildStatCard(
            Icons.event_rounded,
            "$_totalEvents",
            "Events",
            AppGradients.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppEffects.subtleShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
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
        _actionCard(
          "Jobs & Materials",
          Icons.work_rounded,
          AppGradients.accent,
          () => widget.onNavigate(1),
        ),
        _actionCard(
          "Events",
          Icons.event_rounded,
          AppGradients.primary,
          () => widget.onNavigate(2),
        ),
        _actionCard(
          "Notices",
          Icons.campaign_rounded,
          AppGradients.surface,
          () => widget.onNavigate(3),
        ),
        _actionCard(
          "Approvals",
          Icons.verified_user_rounded,
          AppGradients.success,
          () => widget.onNavigate(4),
        ),
        _actionCard(
          "Manage Users",
          Icons.manage_accounts_rounded,
          AppGradients.danger,
          () => widget.onNavigate(5),
        ),
        _actionCard(
          "Library",
          Icons.library_books_rounded,
          AppGradients.surface,
          () => widget.onNavigate(6),
        ),
      ],
    );
  }

  Widget _actionCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return DashboardCard(
      title: title,
      value: "Manage",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }
}
