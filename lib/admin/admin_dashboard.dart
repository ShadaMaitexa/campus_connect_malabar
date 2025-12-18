import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer.dart';
import 'approve_users.dart';
import 'manage_departments.dart';
import 'post_event.dart';
import 'post_global_notice.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const ApproveUsers(),
    const ManageDepartments(),
    const PostEvent(),
    const AdminPostNotice(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    if (isDesktop || isTablet) {
      return Scaffold(
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
            Expanded(
              child: Column(
                children: [
                  AdminAppBar(
                    title: _getTitle(_selectedIndex),
                  ),
                  Expanded(
                    child: _screens[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AdminAppBar(title: _getTitle(_selectedIndex)),
      drawer: Drawer(
        child: AdminSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Approve Users';
      case 2:
        return 'Manage Departments';
      case 3:
        return 'Post Event';
      case 4:
        return 'Post Notice';
      default:
        return 'Admin Panel';
    }
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: AppTheme.heading1,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          _StatsGrid(),
          const SizedBox(height: AppTheme.spacingXL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: Responsive.isDesktop(context) ? 2 : 1,
                child: _RecentActivity(),
              ),
              if (Responsive.isDesktop(context)) ...[
                const SizedBox(width: AppTheme.spacingL),
                Expanded(child: _QuickActions()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _StatsGridShimmer();
        }

        final users = snapshot.data!.docs;
        final totalUsers = users.length;
        final pendingApprovals = users.where((u) => (u['approved'] as bool? ?? false) == false).length;
        final students = users.where((u) => u['role'] == 'student').length;
        final mentors = users.where((u) => u['role'] == 'mentor').length;

        return Responsive.isMobile(context)
            ? Column(
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _StatCard(
                    title: 'Pending Approvals',
                    value: pendingApprovals.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _StatCard(
                    title: 'Students',
                    value: students.toString(),
                    icon: Icons.school_rounded,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _StatCard(
                    title: 'Mentors',
                    value: mentors.toString(),
                    icon: Icons.person_rounded,
                    color: AppTheme.secondaryColor,
                  ),
                ],
              )
            : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.gridCrossAxisCount(context),
                crossAxisSpacing: AppTheme.spacingL,
                mainAxisSpacing: AppTheme.spacingL,
                childAspectRatio: 2.5,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  _StatCard(
                    title: 'Pending Approvals',
                    value: pendingApprovals.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warningColor,
                  ),
                  _StatCard(
                    title: 'Students',
                    value: students.toString(),
                    icon: Icons.school_rounded,
                    color: AppTheme.successColor,
                  ),
                  _StatCard(
                    title: 'Mentors',
                    value: mentors.toString(),
                    icon: Icons.person_rounded,
                    color: AppTheme.secondaryColor,
                  ),
                ],
              );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.heading2.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGridShimmer extends StatelessWidget {
  const _StatsGridShimmer();

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? Column(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: LoadingShimmer(
                  width: double.infinity,
                  height: 100,
                ),
              ),
            ),
          )
        : GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.gridCrossAxisCount(context),
            crossAxisSpacing: AppTheme.spacingL,
            mainAxisSpacing: AppTheme.spacingL,
            childAspectRatio: 2.5,
            children: List.generate(
              4,
              (index) => LoadingShimmer(
                width: double.infinity,
                height: 100,
              ),
            ),
          );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: AppTheme.heading3),
          const SizedBox(height: AppTheme.spacingL),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;
              if (users.isEmpty) {
                return const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No recent activity',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text('${user['role']} • ${user['email']}'),
                    trailing: Text(
                      user['createdAt'] != null
                          ? _formatDate(user['createdAt'].toDate())
                          : 'Recently',
                      style: AppTheme.bodySmall,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTheme.heading3),
          const SizedBox(height: AppTheme.spacingL),
          _ActionButton(
            icon: Icons.people_rounded,
            label: 'Approve Users',
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingM),
          _ActionButton(
            icon: Icons.apartment_rounded,
            label: 'Manage Departments',
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingM),
          _ActionButton(
            icon: Icons.event_rounded,
            label: 'Post Event',
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingM),
          _ActionButton(
            icon: Icons.notifications_rounded,
            label: 'Post Notice',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppTheme.spacingM),
            Text(label, style: AppTheme.bodyMedium),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
