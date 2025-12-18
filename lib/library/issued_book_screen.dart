import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssuedBooksScreen extends StatelessWidget {
  const IssuedBooksScreen({super.key});

  int fine(DateTime returnDate) {
    if (DateTime.now().isBefore(returnDate)) return 0;
    return DateTime.now().difference(returnDate).inDays * 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Return Approvals")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .where('returned', isEqualTo: false)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final returnDate = (doc['returnDate'] as Timestamp).toDate();
              final fineAmount = fine(returnDate);

              return Card(
                child: ListTile(
                  title: Text(doc['bookTitle']),
                  subtitle: Text(
                      "Student: ${doc['studentId']} | Fine: ₹$fineAmount"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await doc.reference.update({'returned': true});
                    },
                    child: const Text("Approve Return"),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
