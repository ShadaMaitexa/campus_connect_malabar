import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/library_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: CustomAppBar(
        title: "Library",
        showBackButton: true,
        gradient: AppGradients.dark,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- MY ISSUED BOOK ----------
          AppAnimations.slideInFromBottom(
            delay: const Duration(milliseconds: 100),
            child: StreamBuilder<QuerySnapshot>(
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
                final reissue = overdueFine ~/ 10 >= 5;

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: overdueFine > 0
                        ? AppGradients.orange
                        : AppGradients.dark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: (overdueFine > 0
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
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
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: const Icon(
                              Icons.book_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "My Issued Book",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        issue['bookTitle'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            overdueFine > 0
                                ? Icons.warning_rounded
                                : Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            overdueFine > 0
                                ? "Overdue • Fine ₹$overdueFine"
                                : "Return by ${returnDate.toLocal().toString().split(' ')[0]}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      if (reissue) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => LibraryService.reissueBook(issue.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.warningColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                              ),
                            ),
                            child: Text(
                              "Re-Issue Book",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // ---------- AVAILABLE BOOKS SECTION ----------
          AppAnimations.slideInFromBottom(
            delay: const Duration(milliseconds: 200),
            child: const SectionHeader(
              title: 'Available Books',
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snap.data!.docs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.library_books_rounded,
                  title: 'No Books Available',
                  subtitle: 'Check back later for new additions',
                );
              }

              return Column(
                children: List.generate(
                  snap.data!.docs.length,
                  (index) {
                    final book = snap.data!.docs[index];
                    return AppAnimations.slideInFromBottom(
                      delay: Duration(milliseconds: 300 + (index * 100)),
                      child: _buildBookCard(
                        context,
                        book,
                        uid,
                        isDark,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    QueryDocumentSnapshot book,
    String uid,
    bool isDark,
  ) {
    final available = book['availableCopies'] > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: Image.network(
                  book['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.book_rounded,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.lightTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book['author'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (available
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              available
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 14,
                              color: available
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${book['availableCopies']} Available",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: available
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Issue Button
            Container(
              decoration: BoxDecoration(
                gradient: available ? AppGradients.primary : null,
                color: available ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: available
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: available
                      ? () {
                          LibraryService.issueBook(
                            bookId: book.id,
                            bookTitle: book['title'],
                            studentId: uid,
                            availableCopies: book['availableCopies'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Book issued successfully!',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                              ),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      "Issue",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: available ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
