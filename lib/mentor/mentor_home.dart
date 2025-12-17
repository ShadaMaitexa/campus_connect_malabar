import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorHome extends StatelessWidget {
  const MentorHome({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dept = snap.data!['department'];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _studentsCount(dept),
              _attendanceStatus(),
              _noticeCount(uid),
              _eventCount(uid),
            ],
          ),
        );
      },
    );
  }

  Widget _studentsCount(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Students", "$count", Icons.group);
      },
    );
  }

  Widget _attendanceStatus() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        final marked = snap.hasData && snap.data!.exists;
        return _card(
          "Attendance",
          marked ? "Marked" : "Pending",
          Icons.check_circle,
          color: marked ? Colors.green : Colors.orange,
        );
      },
    );
  }

  Widget _noticeCount(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Notices", "$count", Icons.campaign);
      },
    );
  }

  Widget _eventCount(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Events", "$count", Icons.event);
      },
    );
  }

  Widget _card(String title, String value, IconData icon,
      {Color color = Colors.blue}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}
