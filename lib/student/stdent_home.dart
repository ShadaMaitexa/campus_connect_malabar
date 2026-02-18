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
import '../widgets/custom_app_bar.dart';

class StudentHome extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const StudentHome({super.key, required this.onNavigate});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome>
    with SingleTickerProviderStateMixin {
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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
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
    // Note: PremiumDashboard/Modern templates usually check screen size
    final isDesktop = MediaQuery.of(context).size.width > 900;

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
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppAnimations.scaleIn(
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunityScreen()),
          ),
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
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          "Student Pulse",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: const [ProfileMenu(), SizedBox(width: 12)],
    );
  }

  Widget _buildGreetingSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAnimations.slideInFromLeft(
          child: Text(
            "Welcome back,",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 4),
        AppAnimations.slideInFromLeft(
          delay: const Duration(milliseconds: 100),
          child: Text(
            _userName ?? "Student",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(bool isDesktop) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance_summary')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        double percentage = 0.0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final present = data['present'] ?? 0;
          final total = data['total'] ?? 0;
          if (total > 0) percentage = (present / total) * 100;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 16) / 2;
            return Row(
              children: [
                _buildModernStatCard(
                  "Attendance",
                  "${percentage.toStringAsFixed(1)}%",
                  Icons.event_available_rounded,
                  AppGradients.blue,
                  cardWidth,
                ),
                const SizedBox(width: 16),
                _buildModernStatCard(
                  "GPA",
                  "3.8",
                  Icons.auto_graph_rounded,
                  AppGradients.purple,
                  cardWidth,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(bool isDesktop) {
    final items = [
      _NavDivider("Academic"),
      _NavItem("Attendance", Icons.fact_check_rounded, AppGradients.blue, 1),
      _NavItem(
        "Internal Marks",
        Icons.assignment_rounded,
        AppGradients.purple,
        2,
      ),
      _NavItem("Notices", Icons.campaign_rounded, AppGradients.danger, 3),
      _NavDivider("Campus Life"),
      _NavItem(
        "Events",
        Icons.event_available_rounded,
        AppGradients.success,
        4,
      ),
      _NavItem("Library", Icons.local_library_rounded, AppGradients.orange, 5),
      _NavItem(
        "Marketplace",
        Icons.shopping_bag_rounded,
        AppGradients.primary,
        6,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.where((i) => i is _NavItem).length,
      itemBuilder: (context, index) {
        final navItems = items.whereType<_NavItem>().toList();
        final item = navItems[index];

        return DashboardCard(
          title: item.title,
          value: "",
          icon: item.icon,
          gradient: item.gradient,
          onTap: () => widget.onNavigate(item.index),
          showArrow: true,
        );
      },
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final int index;
  _NavItem(this.title, this.icon, this.gradient, this.index);
}

class _NavDivider {
  final String title;
  _NavDivider(this.title);
}
