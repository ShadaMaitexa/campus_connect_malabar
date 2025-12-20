import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MentorHome extends StatefulWidget {
  const MentorHome({super.key});

  @override
  State<MentorHome> createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _userName;
  String? _department;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _userName = doc.data()?['name'] ?? 'Mentor';
        _department = doc.data()?['department'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Header
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _userName == null || _department == null
                  ? const ShimmerGrid(itemCount: 4, childAspectRatio: 1.05)
                  : _buildDashboardContent(uid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppAnimations.slideInFromLeft(
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
                          _userName ?? 'Mentor',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_department != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _department!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Mentor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppAnimations.scaleIn(
                    child: const ProfileMenu(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAnimations.slideInFromBottom(
          delay: const Duration(milliseconds: 100),
          child: const SectionHeader(
            title: 'Overview',
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              children: [
                _buildStudentsCount(_department!, 0),
                _buildAttendanceStatus(1),
                _buildNoticeCount(uid, 2),
                _buildEventCount(uid, 3),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        // Quick Stats Section
        AppAnimations.slideInFromBottom(
          delay: const Duration(milliseconds: 300),
          child: _buildQuickStats(),
        ),
      ],
    );
  }

  // ---------------- STUDENTS COUNT ----------------
  Widget _buildStudentsCount(String dept, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return DashboardCard(
          title: "Students",
          value: "$count",
          icon: Icons.group_rounded,
          gradient: AppGradients.blue,
          subtitle: "In your department",
          index: index,
        );
      },
    );
  }

  // ---------------- ATTENDANCE STATUS ----------------
  Widget _buildAttendanceStatus(int index) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        final marked = snap.hasData && snap.data!.exists;
        return DashboardCard(
          title: "Attendance",
          value: marked ? "Marked" : "Pending",
          icon: marked
              ? Icons.check_circle_rounded
              : Icons.pending_actions_rounded,
          gradient: marked ? AppGradients.green : AppGradients.orange,
          subtitle: marked ? "Today's done" : "Mark today",
          index: index,
        );
      },
    );
  }

  // ---------------- NOTICES COUNT ----------------
  Widget _buildNoticeCount(String uid, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return DashboardCard(
          title: "Notices",
          value: "$count",
          icon: Icons.campaign_rounded,
          gradient: AppGradients.purple,
          subtitle: "Posted by you",
          index: index,
        );
      },
    );
  }

  // ---------------- EVENTS COUNT ----------------
  Widget _buildEventCount(String uid, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return DashboardCard(
          title: "Events",
          value: "$count",
          icon: Icons.event_rounded,
          gradient: AppGradients.info,
          subtitle: "Created by you",
          index: index,
        );
      },
    );
  }

  // ---------------- QUICK STATS ----------------
  Widget _buildQuickStats() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Mark Attendance',
                  gradient: AppGradients.green,
                  onTap: () {
                    // Navigate to attendance screen
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add_alert_rounded,
                  label: 'Post Notice',
                  gradient: AppGradients.purple,
                  onTap: () {
                    // Navigate to post notice screen
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.event_available_rounded,
                  label: 'Create Event',
                  gradient: AppGradients.info,
                  onTap: () {
                    // Navigate to create event screen
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.analytics_rounded,
                  label: 'View Reports',
                  gradient: AppGradients.orange,
                  onTap: () {
                    // Navigate to reports screen
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
