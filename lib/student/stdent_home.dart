import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final department = userSnap.data!['department'];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _attendanceCard(uid),
              _todayStatusCard(uid),
              _noticeCountCard(department),
              _eventCountCard(department),
            ],
          ),
        );
      },
    );
  }

  /// ---------- ATTENDANCE PERCENT ----------
  Widget _attendanceCard(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return _card("Attendance", "--", Icons.bar_chart);

        int total = 0;
        int present = 0;

        for (var doc in snap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey(uid)) {
            total++;
            if (data[uid]['present'] == true) present++;
          }
        }

        final percent = total == 0 ? 0 : ((present / total) * 100).round();
        return _card(
          "Attendance",
          "$percent%",
          Icons.bar_chart,
          color: percent >= 75 ? Colors.green : Colors.orange,
        );
      },
    );
  }

  /// ---------- TODAY STATUS ----------
  Widget _todayStatusCard(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return _card("Today", "Not Marked", Icons.help);
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        if (!data.containsKey(uid)) {
          return _card("Today", "Not Marked", Icons.help);
        }

        final present = data[uid]['present'];
        return _card(
          "Today",
          present ? "Present" : "Absent",
          present ? Icons.check_circle : Icons.cancel,
          color: present ? Colors.green : Colors.red,
        );
      },
    );
  }

  /// ---------- NOTICE COUNT ----------
  Widget _noticeCountCard(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Notices", "$count", Icons.notifications);
      },
    );
  }

  /// ---------- EVENT COUNT ----------
  Widget _eventCountCard(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _card("Events", "0", Icons.event);
        }

        final count = snap.data!.docs.where((d) {
          return d['department'] == 'ALL' || d['department'] == dept;
        }).length;

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
