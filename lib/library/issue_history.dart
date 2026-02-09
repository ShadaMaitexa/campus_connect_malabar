import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class IssueHistoryScreen extends StatelessWidget {
  final bool isEmbedded;
  const IssueHistoryScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    if (isEmbedded) {
      return _buildScaffold(context);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/generated_background.png",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: AppTheme.darkBackground.withOpacity(0.92)),
        ),
        _buildScaffold(context),
      ],
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Issue History",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issued_books')
                .orderBy('issuedAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(100),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snap.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(100),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Issue History",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = snap.data!.docs[index];
                    final bool isReturned = doc['returned'] == true;
                    return AppAnimations.slideInFromBottom(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isReturned ? Colors.green : Colors.orange)
                                        .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isReturned
                                    ? Icons.check_circle_rounded
                                    : Icons.pending_actions_rounded,
                                color: isReturned
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['bookTitle'],
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Issued: ${doc['issuedAt'].toDate().toString().split(' ')[0]}",
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isReturned
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isReturned ? "RETURNED" : "PENDING",
                                style: GoogleFonts.inter(
                                  color: isReturned
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: snap.data!.docs.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
