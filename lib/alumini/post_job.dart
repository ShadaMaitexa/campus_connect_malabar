import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostJob extends StatefulWidget {
  const PostJob({super.key});

  @override
  State<PostJob> createState() => _PostJobState();
}

class _PostJobState extends State<PostJob> {
  final company = TextEditingController();
  final role = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();

  bool loading = false;

  Future<void> postJob() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final alumniDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await FirebaseFirestore.instance.collection('jobs').add({
      'company': company.text.trim(),
      'role': role.text.trim(),
      'description': description.text.trim(),
      'location': location.text.trim(),
      'postedBy': alumniDoc['name'],
      'alumniEmail': alumniDoc['email'],
      'createdAt': Timestamp.now(),
    });

    company.clear();
    role.clear();
    description.clear();
    location.clear();

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Job posted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Job Opening")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: company,
              decoration: const InputDecoration(labelText: "Company Name"),
            ),
            TextField(
              controller: role,
              decoration: const InputDecoration(labelText: "Job Role"),
            ),
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: "Job Description"),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: postJob,
                    child: const Text("Post Job"),
                  ),
          ],
        ),
      ),
    );
  }
}
