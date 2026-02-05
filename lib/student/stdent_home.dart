import 'package:campus_connect_malabar/student/attendenceprogress_card.dart';
import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../library/library_screen.dart';
import 'market_place_screen.dart';
import '../alumini/community_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with SingleTickerProviderStateMixin {
  String? _userName;
  String? _department;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted && doc.exists) {
        setState(() {
          _userName = doc.data()?['name'] ?? 'Student';
          _department = doc.data()?['department'] ?? 'General';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDesktop),
          SliverPadding(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(isDesktop),
                  const SizedBox(height: 32),
                  _buildStatsOverview(isDesktop),
                  const SizedBox(height: 48),
                  const SectionHeader(title: "Academic Navigation"),
                  const SizedBox(height: 24),
                  _buildNavigationGrid(isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppAnimations.scaleIn(
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen())),
          label: const Text("Community"),
          icon: const Icon(Icons.groups_rounded),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          "Student Pulse",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions: const [
        ProfileMenu(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildGreetingSection(bool isDesktop) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening";

    return AppAnimations.slideInFromLeft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _userName ?? "Loading...",
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_department != null)
            Text(
              "Dept. of $_department",
              style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isDesktop) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int present = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey(uid)) {
              total++;
              if (data[uid]['present'] == true) present++;
            }
          }
        }
        final percent = total == 0 ? 0 : ((present / total) * 100).round();

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: isDesktop ? 300 : double.infinity,
              child: PremiumStatCard(
                title: "Attendance Rate",
                value: "$percent%",
                icon: Icons.analytics_rounded,
                gradient: percent >= 75 ? AppGradients.primary : AppGradients.accent,
                trend: "$present/$total days",
              ),
            ),
            SizedBox(
              width: isDesktop ? 300 : double.infinity,
              child: const PremiumStatCard(
                title: "Internal GPA",
                value: "3.8/4.0",
                icon: Icons.grade_rounded,
                gradient: AppGradients.success,
                trend: "Top 5%",
              ),
            ),
            if (isDesktop)
            SizedBox(
              width: 300,
              child: const PremiumStatCard(
                title: "Course Progress",
                value: "82%",
                icon: Icons.trending_up_rounded,
                gradient: AppGradients.surface,
                trend: "On schedule",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationGrid(bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _navCard("Library", Icons.local_library_rounded, AppGradients.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen()))),
        _navCard("Marketplace", Icons.store_mall_directory_rounded, AppGradients.accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()))),
        _navCard("Assignments", Icons.assignment_rounded, AppGradients.success, () {}),
        _navCard("Resources", Icons.folder_shared_rounded, AppGradients.surface, () {}),
      ],
    );
  }

  Widget _navCard(String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return DashboardCard(
      title: title,
      value: "Open",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }
}
