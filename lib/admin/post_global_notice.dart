import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPostNotice extends StatefulWidget {
  const AdminPostNotice({super.key});

  @override
  State<AdminPostNotice> createState() => _AdminPostNoticeState();
}

class _AdminPostNoticeState extends State<AdminPostNotice> {
  final title = TextEditingController();
  final message = TextEditingController();

  String department = 'ALL';

  Future<void> postNotice() async {
    await FirebaseFirestore.instance.collection('notices').add({
      'title': title.text.trim(),
      'message': message.text.trim(),
      'department': department,
      'postedBy': 'Admin',
      'role': 'admin',
      'createdAt': Timestamp.now(),
    });

    title.clear();
    message.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notice posted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Notice (Admin)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: message,
              decoration: const InputDecoration(labelText: "Message"),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: postNotice,
              child: const Text("Post Notice"),
            ),
          ],
        ),
      ),
    );
  }
}
