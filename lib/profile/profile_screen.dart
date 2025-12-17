import 'package:campus_connect_malabar/profile/change_password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'mentor_education_form.dart';

import 'terms_conditions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  String role = '';
  String department = '';

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      role = doc['role'];
      department = doc['department'];
      name.text = doc['name'] ?? '';
      phone.text = doc['personalDetails']?['phone'] ?? '';
      address.text = doc['personalDetails']?['address'] ?? '';
    });
  }

  Future<void> saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name.text.trim(),
      'personalDetails': {
        'phone': phone.text.trim(),
        'address': address.text.trim(),
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Role: $role"),
          Text("Department: $department"),
          const Divider(),

          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: "Phone"),
          ),
          TextField(
            controller: address,
            decoration: const InputDecoration(labelText: "Address"),
          ),

          const SizedBox(height: 20),
          ElevatedButton(onPressed: saveProfile, child: const Text("Save")),

          const Divider(),

          if (role == 'mentor')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentorEducationForm(),
                  ),
                );
              },
              child: const Text("Mentor Education Details"),
            ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
            child: const Text("Change Password"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsConditions(),
                ),
              );
            },
            child: const Text("Terms & Conditions"),
          ),
        ],
      ),
    );
  }
}
