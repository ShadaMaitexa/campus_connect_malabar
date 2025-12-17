import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlumniHome extends StatelessWidget {
  const AlumniHome({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _jobsPosted(uid),
          _eventsCount(),
          _engagement(),
          _impact(),
        ],
      ),
    );
  }

  Widget _jobsPosted(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Jobs Posted", "$count", Icons.work);
      },
    );
  }

  Widget _eventsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _card("Events", "$count", Icons.event);
      },
    );
  }

  Widget _engagement() {
    return _card("Engagement", "Active", Icons.trending_up,
        color: Colors.green);
  }

  Widget _impact() {
    return _card("Impact", "Growing", Icons.school,
        color: Colors.blue);
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
