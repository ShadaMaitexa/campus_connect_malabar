import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';

class ViewNotices extends StatelessWidget {
  const ViewNotices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(title: "Notices", showBackButton: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notices')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const ShimmerList(itemCount: 3);
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snap.error}",
                        style: GoogleFonts.poppins(color: AppTheme.errorColor),
                      ),
                    );
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.notifications_off_outlined,
                      title: "No notices available",
                      subtitle: "Check back later for new announcements",
                    );
                  }

                  return Column(
                    children: [
                      AppAnimations.staggeredList(
                        children: snap.data!.docs
                            .map((doc) => _noticeCard(doc))
                            .toList(),
                        staggerDelay: const Duration(milliseconds: 100),
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Fix excess empty space at bottom
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeCard(QueryDocumentSnapshot doc) {
    final role = (doc['role'] ?? 'ADMIN').toString().toUpperCase();
    final isAdmin = role == 'ADMIN';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: AppTheme.darkSurface,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: isAdmin
                        ? AppGradients.danger
                        : AppGradients.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  _formatDate(doc['createdAt']),
                  style: GoogleFonts.inter(
                    color: AppTheme.darkTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              doc['title'] ?? '',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              doc['message'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
