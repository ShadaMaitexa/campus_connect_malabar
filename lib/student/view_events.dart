import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewEvents extends StatelessWidget {
  const ViewEvents({super.key});

  Future<String> getUserDepartment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc['department'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Events")),
      body: FutureBuilder<String>(
        future: getUserDepartment(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final department = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .orderBy('date')
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snap.data!.docs.where((doc) {
                return doc['department'] == 'ALL' ||
                    doc['department'] == department;
              }).toList();

              if (events.isEmpty) {
                return const Center(child: Text("No upcoming events"));
              }

              return ListView(
                children: events.map((doc) {
                  final date = (doc['date'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(doc['title']),
                      subtitle: Text("${doc['description']}\n$date"),
                      isThreeLine: true,
                      trailing: Text(
                        doc['role'].toString().toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
