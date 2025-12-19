import 'package:campus_connect_malabar/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const UnknownRoleScreen();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        /// 🔒 Force profile setup after login
        if (data['profileCompleted'] == false) {
          return const ProfileScreen();
        }

        /// ✅ Route based on role
        switch (role.toLowerCase()) {
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
      },
    );
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
