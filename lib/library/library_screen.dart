import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Campus Library",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Stack(
        children: [
          // Global Premium Background (Nested for transparency)
          Positioned.fill(
            child: Image.asset(
              "assets/images/generated_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.darkBackground.withOpacity(0.92),
            ),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              // ---------- MY ISSUED BOOK ----------
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
                  final returnDate = (issue['returnDate'] as Timestamp).toDate();
                  final overdueFine = fine(returnDate);
                  final reissueAvailable = overdueFine == 0; // Only reissue if no fine

                  return AppAnimations.slideInFromBottom(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: overdueFine > 0
                            ? LinearGradient(colors: [Colors.orange.shade900, Colors.red.shade900])
                            : LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.8), AppTheme.accentColor.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (overdueFine > 0 ? Colors.red : AppTheme.primaryColor).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("CURRENTLY ISSUED", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    Text(issue['bookTitle'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(overdueFine > 0 ? "OVERDUE FINE" : "DUE DATE", style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    overdueFine > 0 ? "₹$overdueFine" : returnDate.toString().split(' ')[0],
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (reissueAvailable)
                                ElevatedButton(
                                  onPressed: () => LibraryService.reissueBook(issue.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text("Re-issue"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ---------- AVAILABLE BOOKS SECTION ----------
              Row(
                children: [
                  Container(width: 4, height: 24, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Text("Explore Collection", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                  if (snap.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.inventory_2_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          Text("No books found", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3))),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisExtent: 180,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, index) {
                      final book = snap.data!.docs[index];
                      return _buildPremiumBookCard(context, book, uid);
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBookCard(BuildContext context, QueryDocumentSnapshot book, String uid) {
    final available = book['availableCopies'] > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Enhanced Book Cover
          Container(
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.book_rounded, color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(book['title'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(book['author'], style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (available ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        available ? "AVAILABLE" : "OUT OF STOCK",
                        style: GoogleFonts.inter(color: available ? Colors.greenAccent : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (available)
                      InkWell(
                        onTap: () async {
                          await LibraryService.issueBook(
                            bookId: book.id,
                            bookTitle: book['title'],
                            studentId: uid,
                            availableCopies: book['availableCopies'],
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book requested successfully!")));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
