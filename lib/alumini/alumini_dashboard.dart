import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'alumini_home.dart';
import 'my_listings.dart';
import 'community_screen.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AlumniHome(),
    MyListings(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  final List<SidebarDestination> _destinations = [
    const SidebarDestination(icon: Icons.dashboard_rounded, label: "Home"),
    const SidebarDestination(icon: Icons.storefront_rounded, label: "Listings"),
    const SidebarDestination(icon: Icons.people_alt_rounded, label: "Community"),
    const SidebarDestination(icon: Icons.person_rounded, label: "Profile"),
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
            icon: Icon(Icons.storefront_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.storefront, color: AppTheme.primaryColor),
            label: "Listings",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.people_alt, color: AppTheme.primaryColor),
            label: "Community",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
