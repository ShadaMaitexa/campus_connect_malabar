import 'package:campus_connect_malabar/alumini/community_screen.dart';
import 'package:campus_connect_malabar/library/library_screen.dart';
import 'package:campus_connect_malabar/student/attendenceprogress_card.dart';
import 'package:campus_connect_malabar/student/market_place_screen.dart';
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

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome>
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
        _userName = doc.data()?['name'] ?? 'Student';
        _department = doc.data()?['department'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
                  ? const ShimmerGrid(itemCount: 6, childAspectRatio: 1.05)
                  : _buildDashboardContent(uid),
            ),
          ),
        ],
      ),
      floatingActionButton: AppAnimations.scaleIn(
        delay: const Duration(milliseconds: 500),
        child: _buildCommunityFAB(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          _userName ?? 'Student',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_department != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _department!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                 AttendanceProgressCard(),
                _buildAttendanceCard(uid, 0),
                _buildTodayStatusCard(uid, 1),
                _buildNoticeCountCard(_department!, 2),
                _buildEventCountCard(_department!, 3),
                _buildLibraryCard(context, 4),
                _buildMarketplaceCard(context, 5),
              ],
            );
          },
        ),
      ],
    );
  }

  // -------------------- ATTENDANCE CARD --------------------
  Widget _buildAttendanceCard(String uid, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return DashboardCard(
            title: "Attendance",
            value: "--",
            icon: Icons.bar_chart_rounded,
            gradient: AppGradients.blue,
            index: index,
          );
        }

        int total = 0;
        int present = 0;

        for (var doc in snap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey(uid)) {
            total++;
            if (data[uid]['present'] == true) present++;
          }
        }

        final percent = total == 0 ? 0 : ((present / total) * 100).round();

        return DashboardCard(
          title: "Attendance",
          value: "$percent%",
          icon: Icons.bar_chart_rounded,
          gradient: percent >= 75 ? AppGradients.green : AppGradients.orange,
          subtitle: "$present/$total days",
          index: index,
        );
      },
    );
  }

  // -------------------- TODAY STATUS CARD --------------------
  Widget _buildTodayStatusCard(String uid, int index) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return DashboardCard(
            title: "Today",
            value: "Not Marked",
            icon: Icons.help_outline_rounded,
            gradient: AppGradients.grey,
            index: index,
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        if (!data.containsKey(uid)) {
          return DashboardCard(
            title: "Today",
            value: "Not Marked",
            icon: Icons.help_outline_rounded,
            gradient: AppGradients.grey,
            index: index,
          );
        }

        final present = data[uid]['present'];

        return DashboardCard(
          title: "Today",
          value: present ? "Present" : "Absent",
          icon: present ? Icons.check_circle_rounded : Icons.cancel_rounded,
          gradient: present ? AppGradients.green : AppGradients.red,
          index: index,
        );
      },
    );
  }

  // -------------------- NOTICES CARD --------------------
  Widget _buildNoticeCountCard(String dept, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;

        return DashboardCard(
          title: "Notices",
          value: "$count",
          icon: Icons.notifications_rounded,
          gradient: AppGradients.purple,
          subtitle: "Active notices",
          index: index,
        );
      },
    );
  }

  // -------------------- EVENTS CARD --------------------
  Widget _buildEventCountCard(String dept, int index) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return DashboardCard(
            title: "Events",
            value: "0",
            icon: Icons.event_rounded,
            gradient: AppGradients.blue,
            index: index,
          );
        }

        final count = snap.data!.docs.where((d) {
          return d['department'] == 'ALL' || d['department'] == dept;
        }).length;

        return DashboardCard(
          title: "Events",
          value: "$count",
          icon: Icons.event_rounded,
          gradient: AppGradients.info,
          subtitle: "Upcoming events",
          index: index,
        );
      },
    );
  }

  // -------------------- LIBRARY CARD --------------------
  Widget _buildLibraryCard(BuildContext context, int index) {
    return DashboardCard(
      title: "Library",
      value: "Books",
      icon: Icons.library_books_rounded,
      gradient: AppGradients.dark,
      showArrow: true,
      index: index,
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slideUp(page: const LibraryScreen()),
        );
      },
    );
  }

  // -------------------- MARKETPLACE CARD --------------------
  Widget _buildMarketplaceCard(BuildContext context, int index) {
    return DashboardCard(
      title: "Marketplace",
      value: "Explore",
      icon: Icons.storefront_rounded,
      gradient: AppGradients.teal,
      showArrow: true,
      index: index,
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slideUp(page: const MarketplaceScreen()),
        );
      },
    );
  }

  // -------------------- COMMUNITY FAB --------------------
  Widget _buildCommunityFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.slideUp(page: const CommunityScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Community",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
