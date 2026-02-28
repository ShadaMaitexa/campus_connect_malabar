import 'package:campus_connect_malabar/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

import 'package:campus_connect_malabar/admin/admin_dashboard.dart';
import 'package:campus_connect_malabar/mentor/mentor_dashboard.dart';
import 'package:campus_connect_malabar/student/student_dashboard.dart';
import 'package:campus_connect_malabar/alumini/alumini_dashboard.dart';
import 'package:campus_connect_malabar/library/library_admin_dashboard.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';

class RoleRouter extends StatelessWidget {
  final String role;

  const RoleRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const UnknownRoleScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
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
          return const ProfileScreen(isFirstTime: true);
        }

        final lowerRole = role.toLowerCase();

        /// 🌐 Platform Specific Gating
        /// Web: Only Admin & Library
        /// App: Student, Mentor, Alumni
        if (kIsWeb) {
          if (lowerRole != 'admin' && lowerRole != 'library') {
            return const MobileOnlyRoleScreen();
          }
        }

        /// ✅ Route based on role
        switch (lowerRole) {
          case 'admin':
            return const AdminDashboard();

          case 'mentor':
            return const MentorDashboard();

          case 'student':
            return const StudentDashboard();

          case 'alumni':
          case 'alumini':
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

class MobileOnlyRoleScreen extends StatelessWidget {
  const MobileOnlyRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_rounded, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                "Mobile App Required",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Student and Faculty features are exclusive to our mobile application. Please download the APK to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                   // Mock interaction
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("APK Download started...")),
                   );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text("Download APK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // AuthWrapper will handle navigation
                },
                child: const Text("Logout", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
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
