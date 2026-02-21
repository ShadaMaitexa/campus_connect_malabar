import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<SidebarDestination> destinations;
  final VoidCallback? onLogout;
  final String userName;
  final String userRole;

  const PremiumSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.onLogout,
    this.userName = "Admin User",
    this.userRole = "Super Admin",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(right: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/icon/logo.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Campus Connect",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // Destinations
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final d = destinations[index];
                final isSelected = selectedIndex == index;
                return _SidebarTile(
                  icon: d.icon,
                  label: d.label,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(index),
                );
              },
            ),
          ),
          // Bottom section
          const Padding(
            padding: EdgeInsets.all(24),
            child: Divider(color: AppTheme.darkBorder),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              userRole,
              style: const TextStyle(
                color: AppTheme.darkTextSecondary,
                fontSize: 12,
              ),
            ),
            trailing: onLogout != null
                ? IconButton(
                    onPressed: onLogout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                    tooltip: "Logout",
                  )
                : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SidebarDestination {
  final IconData icon;
  final String label;
  const SidebarDestination({required this.icon, required this.label});
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            icon,
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.darkTextSecondary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.darkTextSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String trend;
  final bool isPositive;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend = "+12%",
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
        boxShadow: AppEffects.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.blue).withOpacity(
                    0.35,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isPositive ? Colors.greenAccent : Colors.blueAccent)
                        .withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive
                        ? Colors.greenAccent
                        : Colors.lightBlueAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkTextSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
