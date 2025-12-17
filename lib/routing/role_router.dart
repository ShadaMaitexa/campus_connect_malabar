import 'package:flutter/material.dart';

import '../admin/admin_dashboard.dart';
import '../mentor/mentor_dashboard.dart';
import '../student/student_dashboard.dart';
import '../alumini/alumini_dashboard.dart';
import '../library/library_admin_dashboard.dart';

class RoleRouter extends StatelessWidget {
  final String role;

  const RoleRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'admin':
        return const AdminDashboard();

      case 'mentor':
        return const MentorDashboard();

      case 'student':
        return const StudentDashboard();

      case 'alumni':
        return const AlumniDashboard();

      case 'library':
        return const LibraryAdminDashboard();

      default:
        return const UnknownRoleScreen();
    }
  }
}

/// Fallback screen (safety)
class UnknownRoleScreen extends StatelessWidget {
  const UnknownRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Unknown role.\nPlease contact administrator.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
