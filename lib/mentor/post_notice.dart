import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostNotice extends StatefulWidget {
  const PostNotice({super.key});

  @override
  State<PostNotice> createState() => _PostNoticeState();
}

class _PostNoticeState extends State<PostNotice> {
  final title = TextEditingController();
  final message = TextEditingController();

  bool loading = false;

  Future<void> postNotice() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await FirebaseFirestore.instance.collection('notices').add({
      'title': title.text.trim(),
      'message': message.text.trim(),
      'department': userDoc['department'],
      'postedBy': userDoc['name'],
      'role': 'mentor',
      'createdAt': Timestamp.now(),
    });

    title.clear();
    message.clear();

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notice posted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Notice")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Notice Title"),
            ),
            TextField(
              controller: message,
              decoration: const InputDecoration(labelText: "Notice Message"),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: postNotice,
                    child: const Text("Post Notice"),
                  ),
          ],
        ),
      ),
    );
  }
}
