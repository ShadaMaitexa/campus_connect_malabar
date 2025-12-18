import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinePaymentsScreen extends StatelessWidget {
  const FinePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fine Payments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .where('returned', isEqualTo: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(doc['bookTitle']),
                subtitle: Text("Student: ${doc['studentId']}"),
                trailing: const Text("Paid"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
