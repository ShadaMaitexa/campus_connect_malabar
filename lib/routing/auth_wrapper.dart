import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import '../routing/role_router.dart';
import '../profile/profile_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnap.data!;
            final role = userData['role'];
            final approved = userData['approved'];
            final profileCompleted = userData['profileCompleted'];

            // Mentor & Alumni approval check
            if ((role == 'mentor' || role == 'alumni') && !approved) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen(
                message: "Waiting for admin approval",
              );
            }

            // Mandatory profile setup
            if (!profileCompleted) {
              return const ProfileScreen();
            }

            // Route to dashboard
            return RoleRouter(role: role);
          },
        );
      },
    );
  }
}
