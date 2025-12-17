import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'forgot_screen.dart';
import 'register_screen.dart';

import '../admin/admin_dashboard.dart';
import '../mentor/mentor_dashboard.dart';
import '../student/student_dashboard.dart';
import '../alumini/alumini_dashboard.dart';

import '../profile/profile_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  final String? message;
  const LoginScreen({super.key, this.message});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = AuthService();
  final firestore = FirestoreService();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    // 🔴 HARD CODED ADMIN LOGIN
    if (email.text.trim() == "admin@campusconnect.com" &&
        password.text.trim() == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
      return;
    }

    try {
      // Firebase login
      User? user = await auth.login(email.text.trim(), password.text.trim());

      if (user == null) throw Exception("Login failed");

      // Fetch user document
      final userData = await firestore.getUserData(user.uid);

      final role = userData['role'];
      final approved = userData['approved'];
      final profileCompleted = userData['profileCompleted'];

      // 🚫 Approval check (Mentor & Alumni)
      if ((role == 'mentor' || role == 'alumni') && approved == false) {
        await FirebaseAuth.instance.signOut();
        throw Exception("Waiting for admin approval");
      }

      // 📝 Mandatory profile completion
      if (!profileCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        return;
      }

      // 🔀 Role-based dashboard
      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      } else if (role == 'mentor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MentorDashboard()),
        );
      } else if (role == 'alumni') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AlumniDashboard()),
        );
      } else {
        throw Exception("Invalid role");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Connect Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.message!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text("Forgot Password?"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RegisterScreen()),
              ),
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
