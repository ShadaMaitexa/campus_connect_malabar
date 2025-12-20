import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_item.dart';
import 'post_job.dart';
import 'my_listings.dart';

class AlumniHome extends StatefulWidget {
  const AlumniHome({super.key});

  @override
  State<AlumniHome> createState() => _AlumniHomeState();
}

class _AlumniHomeState extends State<AlumniHome> {
  String? _userName;
  String? _company;
  int _materialsCount = 0;
  int _jobsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    // Load user data
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && userDoc.exists) {
      setState(() {
        _userName = userDoc.data()?['name'] ?? 'Alumni';
        _company = userDoc.data()?['company'];
      });
    }

    // Load materials count
    final materialsSnap = await FirebaseFirestore.instance
        .collection('study_materials')
        .where('uploadedBy', isEqualTo: uid)
        .get();

    // Load jobs count
    final jobsSnap = await FirebaseFirestore.instance
        .collection('jobs')
        .where('postedBy', isEqualTo: uid)
        .get();

    if (mounted) {
      setState(() {
        _materialsCount = materialsSnap.docs.length;
        _jobsCount = jobsSnap.docs.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppTheme.darkBackground,
                  AppTheme.darkBackground,
                ]
              : [
                  const Color(0xFF6366F1).withOpacity(0.05),
                  AppTheme.lightBackground,
                ],
        ),
      ),
      child: _isLoading
          ? const Center(
              child: ShimmerGrid(itemCount: 4, childAspectRatio: 1.15),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  AppAnimations.slideInFromBottom(
                    child: _buildWelcomeCard(isDark),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Section
                  AppAnimations.slideInFromBottom(
                    delay: const Duration(milliseconds: 100),
                    child: const SectionHeader(title: 'Your Contributions'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppAnimations.slideInFromLeft(
                          delay: const Duration(milliseconds: 200),
                          child: _buildStatCard(
                            icon: Icons.menu_book_rounded,
                            value: '$_materialsCount',
                            label: 'Materials',
                            gradient: AppGradients.purple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppAnimations.slideInFromRight(
                          delay: const Duration(milliseconds: 200),
                          child: _buildStatCard(
                            icon: Icons.work_rounded,
                            value: '$_jobsCount',
                            label: 'Jobs Posted',
                            gradient: AppGradients.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions Section
                  AppAnimations.slideInFromBottom(
                    delay: const Duration(milliseconds: 300),
                    child: const SectionHeader(title: 'Quick Actions'),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          DashboardCard(
                            title: "Post Material",
                            value: "Share",
                            icon: Icons.menu_book_rounded,
                            gradient: AppGradients.purple,
                            showArrow: true,
                            index: 0,
                            onTap: () => Navigator.push(
                              context,
                              PageTransitions.slideUp(page: const PostItemScreen()),
                            ),
                          ),
                          DashboardCard(
                            title: "Post Job",
                            value: "Hiring",
                            icon: Icons.work_rounded,
                            gradient: AppGradients.info,
                            showArrow: true,
                            index: 1,
                            onTap: () => Navigator.push(
                              context,
                              PageTransitions.slideUp(page: const PostJobScreen()),
                            ),
                          ),
                          DashboardCard(
                            title: "My Listings",
                            value: "View All",
                            icon: Icons.list_alt_rounded,
                            gradient: AppGradients.teal,
                            showArrow: true,
                            index: 2,
                            onTap: () => Navigator.push(
                              context,
                              PageTransitions.slideUp(page: const MyListings()),
                            ),
                          ),
                          DashboardCard(
                            title: "Community",
                            value: "Connect",
                            icon: Icons.people_rounded,
                            gradient: AppGradients.secondary,
                            showArrow: true,
                            index: 3,
                            onTap: () {
                              // Navigate to community
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Tips Section
                  AppAnimations.slideInFromBottom(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTipsCard(isDark),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.secondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName ?? 'Alumni',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_company != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _company!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.warningColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tips for Alumni',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            icon: Icons.upload_file_rounded,
            text: 'Share study materials to help current students',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.work_outline_rounded,
            text: 'Post job openings from your company',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.forum_rounded,
            text: 'Connect with other alumni in the community',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
