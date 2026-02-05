import 'package:campus_connect_malabar/mentor/mentor_home.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'attendance_screen.dart';
import 'post_notice.dart';
import 'post_event.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MentorHome(),
    AttendanceScreen(),
    PostNotice(),
    MentorPostEvent(),
  ];

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Home"),
    const SidebarDestination(icon: Icons.check_circle_rounded, label: "Attendance"),
    const SidebarDestination(icon: Icons.campaign_rounded, label: "Notices"),
    const SidebarDestination(icon: Icons.event_rounded, label: "Events"),
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
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: _destinations,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        height: 70,
        backgroundColor: AppTheme.darkSurface,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.check_circle, color: AppTheme.primaryColor),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.campaign, color: AppTheme.primaryColor),
            label: "Notices",
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.event, color: AppTheme.primaryColor),
            label: "Events",
          ),
        ],
      ),
    );
  }
}
