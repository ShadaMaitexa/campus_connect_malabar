import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentorEducationForm extends StatefulWidget {
  const MentorEducationForm({super.key});

  @override
  State<MentorEducationForm> createState() => _MentorEducationFormState();
}

class _MentorEducationFormState extends State<MentorEducationForm> {
  final institution = TextEditingController();
  final designation = TextEditingController();
  final experience = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final edu = doc['mentorEducation'];
    if (edu != null) {
      institution.text = edu['institution'] ?? '';
      designation.text = edu['designation'] ?? '';
      experience.text = edu['experience'] ?? '';
    }
  }

  Future<void> save() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'mentorEducation': {
        'institution': institution.text.trim(),
        'designation': designation.text.trim(),
        'experience': experience.text.trim(),
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Education details saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentor Education Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: institution,
              decoration: const InputDecoration(labelText: "Institution"),
            ),
            TextField(
              controller: designation,
              decoration: const InputDecoration(labelText: "Designation"),
            ),
            TextField(
              controller: experience,
              decoration: const InputDecoration(labelText: "Experience"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
