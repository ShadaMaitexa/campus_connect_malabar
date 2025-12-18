import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/library_service.dart';

class ManageBooks extends StatelessWidget {
  const ManageBooks({super.key});

  int fine(DateTime returnDate) {
    if (DateTime.now().isBefore(returnDate)) return 0;
    return DateTime.now().difference(returnDate).inDays * 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Library Management",
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEdit(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, bookSnap) {
          if (!bookSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: bookSnap.data!.docs.map((book) {
              return _bookRow(context, book);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _bookRow(BuildContext context, QueryDocumentSnapshot book) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issued_books')
          .where('bookId', isEqualTo: book.id)
          .where('returned', isEqualTo: false)
          .snapshots(),
      builder: (context, issueSnap) {
        final issued = issueSnap.hasData && issueSnap.data!.docs.isNotEmpty;
        int bookFine = 0;

        if (issued) {
          final issue = issueSnap.data!.docs.first;
          bookFine = fine((issue['returnDate'] as Timestamp).toDate());
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book['imageUrl'],
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.menu_book, size: 60),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(book['author'],
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _chip(
                          issued ? "Issued" : "Available",
                          issued ? Colors.orange : Colors.green,
                        ),
                        if (bookFine > 0)
                          _chip("Fine ₹$bookFine", Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _addEdit(context, book: book),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    LibraryService.deleteBook(book.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );

  void _addEdit(BuildContext context, {QueryDocumentSnapshot? book}) {
    final title = TextEditingController(text: book?['title']);
    final author = TextEditingController(text: book?['author']);
    final image = TextEditingController(text: book?['imageUrl']);
    final copies = TextEditingController(
        text: book != null ? book['totalCopies'].toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(book == null ? "Add Book" : "Edit Book"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: author, decoration: const InputDecoration(labelText: "Author")),
            TextField(controller: image, decoration: const InputDecoration(labelText: "Image URL")),
            TextField(controller: copies, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Total Copies")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (book == null) {
                await LibraryService.addBook(
                  title: title.text,
                  author: author.text,
                  imageUrl: image.text,
                  totalCopies: int.parse(copies.text),
                );
              } else {
                await LibraryService.updateBook(
                  bookId: book.id,
                  title: title.text,
                  author: author.text,
                  imageUrl: image.text,
                  totalCopies: int.parse(copies.text),
                  availableCopies: book['availableCopies'],
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
