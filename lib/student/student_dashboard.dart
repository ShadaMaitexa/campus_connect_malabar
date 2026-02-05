import 'package:campus_connect_malabar/student/attendence_view.dart';
import 'package:campus_connect_malabar/student/stdent_home.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'view_notices.dart';
import 'view_events.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StudentHome(),
    StudentAttendanceView(),
    ViewNotices(),
    ViewEvents(),
  ];

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Home"),
    const SidebarDestination(icon: Icons.bar_chart_rounded, label: "Attendance"),
    const SidebarDestination(icon: Icons.notifications_rounded, label: "Notices"),
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
            icon: Icon(Icons.bar_chart_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primaryColor),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.notifications, color: AppTheme.primaryColor),
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
