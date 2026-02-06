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
            _navItem(Icons.storefront_outlined, Icons.storefront_rounded, "Listings"),
            _navItem(Icons.people_alt_outlined, Icons.people_alt_rounded, "Community"),
            _navItem(Icons.person_outline, Icons.person_rounded, "Profile"),
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
