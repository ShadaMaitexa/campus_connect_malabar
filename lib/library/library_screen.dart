import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/library_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  int fine(DateTime returnDate) =>
      DateTime.now().isAfter(returnDate)
          ? DateTime.now().difference(returnDate).inDays * 10
          : 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Library",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- MY BOOK ----------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issued_books')
                .where('studentId', isEqualTo: uid)
                .where('returned', isEqualTo: false)
                .limit(1)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const SizedBox();
              }

              final issue = snap.data!.docs.first;
              final returnDate =
                  (issue['returnDate'] as Timestamp).toDate();
              final overdueFine = fine(returnDate);
              final reissue = overdueFine ~/ 10 >= 5;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("My Issued Book",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(issue['bookTitle'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(
                      overdueFine > 0
                          ? "Overdue • Fine ₹$overdueFine"
                          : "Return by ${returnDate.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(
                          color: overdueFine > 0
                              ? Colors.orangeAccent
                              : Colors.white70),
                    ),
                    if (reissue)
                      ElevatedButton(
                        onPressed: () => LibraryService.reissueBook(issue.id),
                        child: const Text("Re-Issue"),
                      )
                  ],
                ),
              );
            },
          ),

          const Text("Available Books",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: snap.data!.docs.map((book) {
                  final available = book['availableCopies'] > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.network(book['imageUrl'],
                            width: 50, height: 70),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(book['author'],
                                  style: const TextStyle(
                                      color: Colors.black54)),
                              Text(
                                  "Available: ${book['availableCopies']}",
                                  style: TextStyle(
                                      color: available
                                          ? Colors.green
                                          : Colors.red)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: available
                              ? () => LibraryService.issueBook(
                                    bookId: book.id,
                                    bookTitle: book['title'],
                                    studentId: uid,
                                    availableCopies:
                                        book['availableCopies'],
                                  )
                              : null,
                          child: const Text("Issue"),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
