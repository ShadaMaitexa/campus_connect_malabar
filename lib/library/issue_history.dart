import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueHistoryScreen extends StatelessWidget {
  const IssueHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .orderBy('issuedAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['bookTitle']),
                  subtitle: Text(
                      "Issued: ${doc['issuedAt'].toDate().toString().split(' ')[0]}"),
                  trailing: Text(
                      doc['returned'] ? "Returned" : "Not Returned"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
