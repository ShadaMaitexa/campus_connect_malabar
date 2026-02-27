import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdminLibrary extends StatefulWidget {
  const AdminLibrary({super.key});

  @override
  State<AdminLibrary> createState() => _AdminLibraryState();
}

class _AdminLibraryState extends State<AdminLibrary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Library Management",
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white38,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Issued Books"),
            Tab(text: "All Books"),
            Tab(text: "Return Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _IssuedBooksTab(),
          _AllBooksTab(),
          _ReturnRequestsTab(),
        ],
      ),
    );
  }
}

// ─── Issued Books Tab ─────────────────────────────────────────────────────────
class _IssuedBooksTab extends StatelessWidget {
  Future<String> _getStudentName(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();
    if (!doc.exists) return "Unknown Student";
    return doc.data()?['name'] ?? "Unknown Student";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issued_books')
          .orderBy('issuedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_rounded,
                    size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text("No issued books found",
                    style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.3))),
              ],
            ),
          );
        }

        final issues = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: issues.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final issue = issues[index].data() as Map<String, dynamic>;
            final String studentId = issue['studentId'] ?? '';
            final bool isReturned = issue['returned'] == true;
            final returnDate = issue['returnDate'];
            final String returnStr = returnDate != null
                ? (returnDate as Timestamp).toDate().toString().split(' ')[0]
                : 'N/A';

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isReturned ? Colors.green : Colors.orange)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isReturned
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      color: isReturned ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue['bookTitle'] ?? 'Unknown Book',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        FutureBuilder<String>(
                          future: _getStudentName(studentId),
                          builder: (context, snap) {
                            return Text(
                              "Issued to: ${snap.data ?? '...'}",
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 13),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Return by: $returnStr",
                          style: GoogleFonts.inter(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isReturned
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isReturned ? "RETURNED" : "DUE",
                      style: GoogleFonts.inter(
                        color:
                            isReturned ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── All Books Tab ─────────────────────────────────────────────────────────────
class _AllBooksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .orderBy('title')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined,
                    size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text("No books in inventory",
                    style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.3))),
              ],
            ),
          );
        }

        final books = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: books.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final book = books[index].data() as Map<String, dynamic>;
            final int total = book['totalCopies'] ?? 0;
            final int available = book['availableCopies'] ?? 0;
            final String imageUrl = book['imageUrl'] ?? '';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  // Book Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl,
                            width: 56,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _bookPlaceholder())
                        : _bookPlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] ?? 'Untitled',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "by ${book['author'] ?? 'Unknown'}",
                          style: GoogleFonts.inter(
                              color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _pill("$available available",
                                available > 0 ? Colors.green : Colors.red),
                            const SizedBox(width: 8),
                            _pill("$total total", Colors.white24),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 18),
                    ),
                    onPressed: () async {
                      final confirm = await _confirmDelete(
                          context, book['title'] ?? 'this book');
                      if (confirm) await books[index].reference.delete();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _bookPlaceholder() {
    return Container(
      width: 56,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.book_rounded,
          color: AppTheme.primaryColor, size: 28),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
            color: color == Colors.white24 ? Colors.white38 : color,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.darkSurface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text("Remove Book",
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text('Remove "$title" from the library?',
                style: GoogleFonts.inter(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel",
                    style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Remove"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ─── Return Requests Tab ───────────────────────────────────────────────────────
class _ReturnRequestsTab extends StatelessWidget {
  Future<String> _getStudentName(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();
    if (!doc.exists) return "Unknown Student";
    return doc.data()?['name'] ?? "Unknown Student";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('return_requests')
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_return_rounded,
                    size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text("No pending return requests",
                    style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.3))),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final req = requests[index].data() as Map<String, dynamic>;
            final docRef = requests[index].reference;
            final studentId = req['studentId'] ?? '';
            final status = req['status'] ?? 'pending';

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_return_rounded,
                            color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req['bookTitle'] ?? 'Unknown Book',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder<String>(
                              future: _getStudentName(studentId),
                              builder: (context, snap) => Text(
                                snap.data ?? '...',
                                style: GoogleFonts.inter(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: GoogleFonts.inter(
                            color: status == 'approved'
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            await docRef.update({'status': 'rejected'});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Return request rejected")),
                              );
                            }
                          },
                          child: const Text("Reject",
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            // Approve: mark as approved, update issued_books
                            final batch = FirebaseFirestore.instance.batch();
                            batch.update(docRef, {'status': 'approved'});

                            // Find the issued_books record and mark as returned
                            final issuedQuery = await FirebaseFirestore.instance
                                .collection('issued_books')
                                .where('bookId',
                                    isEqualTo: req['bookId'])
                                .where('studentId', isEqualTo: studentId)
                                .where('returned', isEqualTo: false)
                                .limit(1)
                                .get();

                            if (issuedQuery.docs.isNotEmpty) {
                              batch.update(
                                  issuedQuery.docs.first.reference,
                                  {'returned': true});
                            }

                            // Increment available copies
                            if (req['bookId'] != null) {
                              final bookRef = FirebaseFirestore.instance
                                  .collection('books')
                                  .doc(req['bookId']);
                              final bookDoc = await bookRef.get();
                              if (bookDoc.exists) {
                                final current =
                                    (bookDoc.data()?['availableCopies'] ?? 0)
                                        as int;
                                batch.update(bookRef,
                                    {'availableCopies': current + 1});
                              }
                            }

                            await batch.commit();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Return approved successfully"),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          },
                          child: const Text("Approve Return",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
