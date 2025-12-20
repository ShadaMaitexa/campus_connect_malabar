import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IssuedBookScreen extends StatelessWidget {
  const IssuedBookScreen({super.key});

  bool _canReturn(Timestamp returnDate, bool returned) {
    final now = DateTime.now();
    return !returned && now.isAfter(returnDate.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Issued Books")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .where('studentId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No books issued"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final book = docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(book['bookTitle']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Issued on: ${book['issuedAt'].toDate()}",
                      ),
                      Text(
                        "Return date: ${book['returnDate'].toDate()}",
                      ),
                      Text(
                        book['returned']
                            ? "Status: Returned"
                            : "Status: Not Returned",
                        style: TextStyle(
                          color: book['returned']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: _canReturn(
                          book['returnDate'], book['returned'])
                      ? TextButton(
                          child: const Text("Return"),
                          onPressed: () async {
                            // Mark as returned
                            await FirebaseFirestore.instance
                                .collection('issued_books')
                                .doc(book.id)
                                .update({
                              'returned': true,
                              'returnedAt':
                                  FieldValue.serverTimestamp(),
                            });

                            // Increase available copies
                            await FirebaseFirestore.instance
                                .collection('books')
                                .doc(book['bookId'])
                                .update({
                              'availableCopies':
                                  FieldValue.increment(1),
                            });
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
