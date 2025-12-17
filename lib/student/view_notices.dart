import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewNotices extends StatelessWidget {
  const ViewNotices({super.key});

  Future<String> getStudentDepartment() async {
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
      appBar: AppBar(title: const Text("Notices")),
      body: FutureBuilder<String>(
        future: getStudentDepartment(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final department = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notices')
                .where('department', isEqualTo: department)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.data!.docs.isEmpty) {
                return const Center(child: Text("No notices available"));
              }

              return ListView(
                children: snap.data!.docs.map((doc) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['message']),
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
