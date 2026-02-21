import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'post_item.dart';
import 'post_job.dart';
import 'my_listings.dart';
import '../widgets/custom_app_bar.dart';

class AlumniHome extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const AlumniHome({super.key, required this.onNavigate});

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final materialsSnap = await FirebaseFirestore.instance
          .collection('marketplace')
          .where('postedBy', isEqualTo: uid)
          .where('type', isEqualTo: 'material')
          .get();

      final jobsSnap = await FirebaseFirestore.instance
          .collection('marketplace')
          .where('postedBy', isEqualTo: uid)
          .where('type', isEqualTo: 'job')
          .get();

      if (mounted) {
        setState(() {
          _userName = userDoc.data()?['name'] ?? 'Alumni';
          _company = userDoc.data()?['company'] ?? 'Mentoring';
          _materialsCount = materialsSnap.docs.length;
          _jobsCount = jobsSnap.docs.length;
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
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                  SectionHeader(title: "Alumni Ecosystem"),
                  const SizedBox(height: 24),
                  _buildActionGrid(isDesktop),
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
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor:
          AppTheme.darkBackground, // Solid background to prevent overlap
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        centerTitle: false,
        title: Text(
          "Alumni Network",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppTheme.darkBackground),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.secondaryColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: const [ProfileMenu(), SizedBox(width: 16)],
    );
  }

  Widget _buildGreetingSection(bool isDesktop) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 17
        ? "Good Afternoon"
        : "Good Evening";

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
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _userName ?? "...",
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_company != null)
            Text(
              "Global Alumni • $_company",
              style: GoogleFonts.inter(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isDesktop) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: PremiumStatCard(
            title: "Shared Materials",
            value: "$_materialsCount",
            icon: Icons.menu_book_rounded,
            gradient: AppGradients.primary,
            trend: "Lives impacted",
          ),
        ),
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: PremiumStatCard(
            title: "Open Opportunities",
            value: "$_jobsCount",
            icon: Icons.work_rounded,
            gradient: AppGradients.info,
            trend: "Jobs posted",
          ),
        ),
        if (isDesktop)
          const SizedBox(
            width: 300,
            child: PremiumStatCard(
              title: "Network Nodes",
              value: "1.2k",
              icon: Icons.hub_rounded,
              gradient: AppGradients.secondary,
              trend: "Global reach",
            ),
          ),
      ],
    );
  }

  Widget _buildActionGrid(bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _navCard(
          "Post Material",
          Icons.publish_rounded,
          AppGradients.primary,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostItemScreen()),
          ),
        ),
        _navCard(
          "Hiring / Job",
          Icons.work_outline_rounded,
          AppGradients.info,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          ),
        ),
        _navCard(
          "My Contributions",
          Icons.analytics_outlined,
          AppGradients.teal,
          () => widget.onNavigate(1),
        ),
        _navCard(
          "Global Community",
          Icons.public_rounded,
          AppGradients.secondary,
          () => widget.onNavigate(2),
        ),
      ],
    );
  }

  Widget _navCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return DashboardCard(
      title: title,
      value: "Action",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }
}
