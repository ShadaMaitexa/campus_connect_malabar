import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today =
        DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('attendance')
            .doc(today)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists ||
              !(snapshot.data!.data() as Map<String, dynamic>)
                  .containsKey(uid)) {
            return const Center(
              child: Text("Attendance not marked today"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;
          final present = data[uid]['present'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  present ? Icons.check_circle : Icons.cancel,
                  color: present ? Colors.green : Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  present ? "PRESENT" : "ABSENT",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
