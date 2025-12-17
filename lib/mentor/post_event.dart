import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorPostEvent extends StatefulWidget {
  const MentorPostEvent({super.key});

  @override
  State<MentorPostEvent> createState() => _MentorPostEventState();
}

class _MentorPostEventState extends State<MentorPostEvent> {
  final title = TextEditingController();
  final description = TextEditingController();
  DateTime eventDate = DateTime.now();

  Future<void> postEvent() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final mentorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await FirebaseFirestore.instance.collection('events').add({
      'title': title.text.trim(),
      'description': description.text.trim(),
      'date': Timestamp.fromDate(eventDate),
      'department': mentorDoc['department'],
      'postedBy': mentorDoc['name'],
      'role': 'mentor',
      'createdAt': Timestamp.now(),
    });

    title.clear();
    description.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event posted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Event")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Event Title"),
            ),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: "Event Description"),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text("Event Date: ${eventDate.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: eventDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => eventDate = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: postEvent,
              child: const Text("Post Event"),
            ),
          ],
        ),
      ),
    );
  }
}
