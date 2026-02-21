import 'package:campus_connect_malabar/mentor/mentor_home.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import 'attendance_screen.dart';
import 'post_notice.dart';
import 'post_event.dart';
import 'student_reports.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    MentorHome(
      onNavigate: (index) {
        setState(() => _selectedIndex = index);
      },
    ),
    const AttendanceScreen(),
    const PostNotice(),
    const MentorPostEvent(),
    const StudentReportsScreen(),
  ];

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Home"),
    const SidebarDestination(
      icon: Icons.check_circle_rounded,
      label: "Attendance",
    ),
    const SidebarDestination(icon: Icons.campaign_rounded, label: "Notices"),
    const SidebarDestination(icon: Icons.event_rounded, label: "Events"),
    const SidebarDestination(icon: Icons.analytics_rounded, label: "Reports"),
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
            child: Container(color: AppTheme.darkBackground.withOpacity(0.92)),
          ),
          Row(
            children: [
              PremiumSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                destinations: _destinations,
                onLogout: _handleLogout,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _screens[_selectedIndex],
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
                child: _screens[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          height: 70,
          backgroundColor: AppTheme.darkBackground.withOpacity(0.95),
          indicatorColor: AppTheme.primaryColor.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 0,
          destinations: [
            _navItem(Icons.dashboard_outlined, Icons.dashboard_rounded, "Home"),
            _navItem(
              Icons.check_circle_outline,
              Icons.check_circle_rounded,
              "Attendance",
            ),
            _navItem(
              Icons.campaign_outlined,
              Icons.campaign_rounded,
              "Notices",
            ),
            _navItem(Icons.event_outlined, Icons.event_rounded, "Events"),
            _navItem(
              Icons.analytics_outlined,
              Icons.analytics_rounded,
              "Reports",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
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

  NavigationDestination _navItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.white54, size: 22),
      selectedIcon: Icon(activeIcon, color: AppTheme.primaryColor, size: 24),
      label: label,
    );
  }
}
