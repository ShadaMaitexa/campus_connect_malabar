import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryService {
  static final _db = FirebaseFirestore.instance;

  // ================= BOOK CRUD =================

  static Future<void> addBook({
    required String title,
    required String author,
    required String imageUrl,
    required int totalCopies,
  }) async {
    await _db.collection('books').add({
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'totalCopies': totalCopies,
      'availableCopies': totalCopies,
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String imageUrl,
    required int totalCopies,
    required int availableCopies,
  }) async {
    await _db.collection('books').doc(bookId).update({
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
    });
  }

  static Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  // ================= ISSUE / REISSUE =================

  static Future<void> issueBook({
    required String bookId,
    required String bookTitle,
    required String studentId,
    required int availableCopies,
  }) async {
    final issuedAt = DateTime.now();
    final returnDate = issuedAt.add(const Duration(days: 7));

    final batch = _db.batch();

    final issueRef = _db.collection('issued_books').doc();

    batch.set(issueRef, {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'studentId': studentId,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'returnDate': Timestamp.fromDate(returnDate),
      'returned': false,
    });

    batch.update(_db.collection('books').doc(bookId), {
      'availableCopies': availableCopies - 1,
    });

    await batch.commit();
  }

  static Future<void> reissueBook(String issueId) async {
    final newReturn =
        DateTime.now().add(const Duration(days: 7));

    await _db.collection('issued_books').doc(issueId).update({
      'returnDate': Timestamp.fromDate(newReturn),
    });
  }
}
