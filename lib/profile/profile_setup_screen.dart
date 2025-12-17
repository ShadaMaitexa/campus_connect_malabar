import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name.text.trim(),
      'personalDetails': {
        'phone': phone.text.trim(),
        'address': address.text.trim(),
      },
      'profileCompleted': true,
    });

    Navigator.pop(context); // AuthWrapper will redirect to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save & Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
