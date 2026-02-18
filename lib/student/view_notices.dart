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
        appBar: const CustomAppBar(
          title: "Announcements",
          subtitle: "Latest Updates",
          showBackButton: true,
          gradient: AppGradients.blue,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppGradients.blue.colors.first.withOpacity(0.08),
                AppTheme.darkBackground,
              ],
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notices')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: ShimmerList(itemCount: 4),
                );
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
                  icon: Icons.notifications_off_rounded,
                  title: "No Announcements",
                  subtitle: "You're all caught up! Check back later.",
                );
              }

              final docs = snap.data!.docs;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return AppAnimations.slideInFromBottom(
                          delay: Duration(milliseconds: index * 100),
                          child: _noticeCard(docs[index]),
                        );
                      }, childCount: docs.length),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _noticeCard(QueryDocumentSnapshot doc) {
    final role = (doc['role'] ?? 'ADMIN').toString().toUpperCase();
    final isAdmin = role == 'ADMIN';
    final title = doc['title'] ?? 'Notice';
    final content = doc['content'] ?? 'No description provided';
    final date = _formatDate(doc['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAdmin
              ? AppTheme.errorColor.withOpacity(0.2)
              : AppTheme.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                // Refined Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AppTheme.errorColor.withOpacity(0.15)
                        : AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAdmin
                          ? AppTheme.errorColor.withOpacity(0.3)
                          : AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                        size: 12,
                        color: isAdmin
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isAdmin
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.darkTextSecondary,
                height: 1.6,
              ),
            ),
          ),

          // Bottom visual indicator for Admin notices
          if (isAdmin)
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.errorColor.withOpacity(0.5),
                    AppTheme.errorColor.withOpacity(0),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recent';
    final date = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return "Today";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return "${date.day}/${date.month}/${date.year}";
  }
}
