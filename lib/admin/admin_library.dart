import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdminLibrary extends StatelessWidget {
  const AdminLibrary({super.key});

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Library Overview",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .orderBy('issuedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString(), style: const TextStyle(color: Colors.redAccent)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text("No issued books found", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3))),
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
              final String studentId = issue['studentId'];
              final bool isReturned = issue['returned'] == true;

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
                        color: (isReturned ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isReturned ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
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
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _getStudentName(studentId),
                            builder: (context, snap) {
                              return Text(
                                "Issued to: ${snap.data ?? '...'}",
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Return by: ${issue['returnDate'].toDate().toString().split(' ')[0]}",
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isReturned ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isReturned ? "RETURNED" : "DUE",
                        style: GoogleFonts.inter(
                          color: isReturned ? Colors.greenAccent : Colors.redAccent,
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
      ),
    );
  }
}
