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
            child: Container(
              color: AppTheme.darkBackground.withOpacity(0.92),
            ),
          ),
          Row(
            children: [
              PremiumSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                destinations: _destinations,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/generated_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.darkBackground.withOpacity(0.92),
            ),
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
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
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
            _navItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, "Attendance"),
            _navItem(Icons.notifications_outlined, Icons.notifications_rounded, "Notices"),
            _navItem(Icons.event_outlined, Icons.event_rounded, "Events"),
          ],
        ),
      ),
    );
  }

  NavigationDestination _navItem(IconData icon, IconData activeIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.white54, size: 22),
      selectedIcon: Icon(activeIcon, color: AppTheme.primaryColor, size: 24),
      label: label,
    );
  }
}
