import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';

class ViewNotices extends StatelessWidget {
  const ViewNotices({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
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

                  return AppAnimations.staggeredList(
                    children: snap.data!.docs
                        .map((doc) => _noticeCard(doc, isDark))
                        .toList(),
                    staggerDelay: const Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- NOTICE CARD ----------------
  Widget _noticeCard(QueryDocumentSnapshot doc, bool isDark) {
    final role = (doc['role'] ?? 'ADMIN').toString().toUpperCase();
    final isAdmin = role == 'ADMIN';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppTheme.darkSurface,
                  AppTheme.darkSurface.withOpacity(0.8),
                ],
              )
            : const LinearGradient(
                colors: [Color(0xFFF8FAFF), Color(0xFFE9EEFF)],
              ),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Role badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAdmin ? AppTheme.errorColor : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Title
            Text(
              doc['title'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 6),

            // 🔹 Message
            Text(
              doc['message'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
