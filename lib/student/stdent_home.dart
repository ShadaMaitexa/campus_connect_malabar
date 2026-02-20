import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../alumini/community_screen.dart';
import 'package:campus_connect_malabar/student/market_place_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../library/library_screen.dart';

class StudentHome extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const StudentHome({super.key, required this.onNavigate});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome>
    with SingleTickerProviderStateMixin {
  String? _userName;
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "Student Pulse",
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w900,
          fontSize: 24,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
      actions: const [ProfileMenu(), SizedBox(width: 12)],
    );
  }

  Widget _buildGreetingSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
    final navItems = [
      _NavItem("Attendance", Icons.fact_check_rounded, AppGradients.blue, 1),
      _NavItem("Notices", Icons.campaign_rounded, AppGradients.danger, 2),
      _NavItem(
        "Events",
        Icons.event_available_rounded,
        AppGradients.success,
        3,
      ),
      _NavItem("Library", Icons.local_library_rounded, AppGradients.orange, -1),
      _NavItem(
        "Marketplace",
        Icons.shopping_bag_rounded,
        AppGradients.primary,
        -2,
      ),
      _NavItem("Community", Icons.groups_rounded, AppGradients.blue, -4),
      _NavItem(
        "Internal Marks",
        Icons.assignment_rounded,
        AppGradients.purple,
        -3,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];

        return DashboardCard(
          title: item.title,
          value: "",
          icon: item.icon,
          gradient: item.gradient,
          onTap: () async {
            try {
              if (item.index >= 0) {
                widget.onNavigate(item.index);
              } else if (item.index == -1) {
                if (!mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryScreen(),
                  ),
                );
              } else if (item.index == -2) {
                if (!mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketplaceScreen(),
                  ),
                );
              } else if (item.index == -3) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Internal Marks coming soon!")),
                );
              } else if (item.index == -4) {
                if (!mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityScreen(),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Navigation error: $e")));
              }
            }
          },
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
