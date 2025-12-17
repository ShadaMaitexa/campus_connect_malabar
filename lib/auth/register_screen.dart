import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = AuthService();
  final firestore = FirestoreService();

  String role = 'student';
  String? department;

  bool loading = false;
  List<String> departments = [];

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    final list = await firestore.getDepartments();
    setState(() {
      departments = list;
      if (list.isNotEmpty) department = list.first;
    });
  }

  Future<void> register() async {
    if (department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No departments found")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      User? user = await auth.register(
        email.text.trim(),
        password.text.trim(),
      );

      if (user == null) throw Exception("Registration failed");

      await firestore.createUser(
        uid: user.uid,
        name: name.text.trim(),
        email: email.text.trim(),
        role: role,
        department: department!,
      );

      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role == 'student'
                ? "Registration successful. Please login."
                : "Registration successful. Await admin approval.",
          ),
        ),
      );

      Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Full Name"),
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

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: "Role"),
              items: const [
                DropdownMenuItem(value: 'student', child: Text("Student")),
                DropdownMenuItem(value: 'mentor', child: Text("Mentor")),
                DropdownMenuItem(value: 'alumni', child: Text("Alumni")),
              ],
              onChanged: (v) => setState(() => role = v!),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: department,
              decoration: const InputDecoration(labelText: "Department"),
              items: departments
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(d),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => department = v),
            ),

            const SizedBox(height: 24),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
