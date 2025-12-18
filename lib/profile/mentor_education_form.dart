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
  bool loading = false;

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

    final edu = doc.data()?['mentorEducation'];
    if (edu != null) {
      institution.text = edu['institution'] ?? '';
      designation.text = edu['designation'] ?? '';
      experience.text = edu['experience'] ?? '';
    }
  }

  Future<void> save() async {
    if (institution.text.isEmpty ||
        designation.text.isEmpty ||
        experience.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'mentorEducation': {
        'institution': institution.text.trim(),
        'designation': designation.text.trim(),
        'experience': experience.text.trim(),
      }
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Education details saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Education Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // MAIN CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mentor Academic Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "These details help students understand your academic background.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INSTITUTION
                  TextField(
                    controller: institution,
                    decoration: InputDecoration(
                      labelText: "Institution / College",
                      prefixIcon: const Icon(Icons.account_balance),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DESIGNATION
                  TextField(
                    controller: designation,
                    decoration: InputDecoration(
                      labelText: "Designation",
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // EXPERIENCE
                  TextField(
                    controller: experience,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Years of Experience",
                      prefixIcon: const Icon(Icons.timeline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SAVE BUTTON
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Details"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
