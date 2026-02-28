import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class DepartmentUsersScreen extends StatefulWidget {
  final String department;
  const DepartmentUsersScreen({super.key, required this.department});

  @override
  State<DepartmentUsersScreen> createState() => _DepartmentUsersScreenState();
}

class _DepartmentUsersScreenState extends State<DepartmentUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> roles = ['student', 'mentor', 'alumni'];
  final List<String> tabTitles = ['Students', 'Mentors', 'Alumni'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: roles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: '${widget.department} Users',
          subtitle: 'Manage department members',
          showBackButton: true,
          gradient: AppGradients.primary,
        ),
        body: Column(
          children: [
            Container(
              color: AppTheme.darkSurface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.white54,
                tabs: tabTitles.map((t) => Tab(text: t)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: roles.map((role) => _RoleUserList(department: widget.department, role: role)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleUserList extends StatelessWidget {
  final String department;
  final String role;
  const _RoleUserList({required this.department, required this.role});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('department', isEqualTo: department)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where((doc) {
           final data = doc.data() as Map<String, dynamic>;
           final r = data['role']?.toString().toLowerCase() ?? '';
           if (role == 'alumni' && (r == 'alumni' || r == 'alumini')) return true;
           return r == role;
        }).toList();

        if (users.isEmpty) {
          return Center(
            child: Text(
              "No users found in this category",
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final name = user['name'] ?? 'Unknown';
            final email = user['email'] ?? '';
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
