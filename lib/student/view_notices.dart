import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';

class ViewNotices extends StatelessWidget {
  const ViewNotices({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: const CustomAppBar(title: "Notices", showBackButton: true),
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
                          style: GoogleFonts.poppins(
                            color: AppTheme.errorColor,
                          ),
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
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isAdmin
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_rounded,
                    color: isAdmin
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    role,
                    style: GoogleFonts.poppins(
                      color: isAdmin
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(doc['createdAt']),
                    style: GoogleFonts.inter(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['title'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc['content'] ?? 'No Content',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.darkTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
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
