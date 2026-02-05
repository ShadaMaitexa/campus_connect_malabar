import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/premium_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'attendance_screen.dart';
import 'post_notice.dart';
import 'post_event.dart';
import '../widgets/custom_app_bar.dart';

class MentorHome extends StatefulWidget {
  const MentorHome({super.key});

  @override
  State<MentorHome> createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome> with SingleTickerProviderStateMixin {
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
          _userName = doc.data()?['name'] ?? 'Mentor';
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
                  SectionHeader(title: "Academic Management"),
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
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          "Mentor Dashboard",
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
              const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Prof. ${_userName ?? "..."}",
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_department != null)
            Text(
              "Department of $_department",
              style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isDesktop) {
    final dept = _department ?? "";
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').where('department', isEqualTo: dept).snapshots(),
            builder: (context, snap) {
              final count = snap.hasData ? snap.data!.docs.length : 0;
              return PremiumStatCard(
                title: "Assigned Students",
                value: "$count",
                icon: Icons.groups_rounded,
                gradient: AppGradients.primary,
                trend: "In your Dept",
              );
            },
          ),
        ),
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: const PremiumStatCard(
            title: "Pending Notices",
            value: "2",
            icon: Icons.campaign_rounded,
            gradient: AppGradients.accent,
            trend: "Awaiting review",
          ),
        ),
        if (isDesktop)
        const SizedBox(
          width: 300,
          child: PremiumStatCard(
            title: "Events This Month",
            value: "14",
            icon: Icons.event_available_rounded,
            gradient: AppGradients.success,
            trend: "+2 from last",
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
        _navCard("Mark Attendance", Icons.how_to_reg_rounded, AppGradients.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _navCard("Post Notice", Icons.add_alert_rounded, AppGradients.accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostNotice()))),
        _navCard("New Event", Icons.event_note_rounded, AppGradients.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentorPostEvent()))),
        _navCard("Student Reports", Icons.analytics_rounded, AppGradients.surface, () {}),
      ],
    );
  }

  Widget _navCard(String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return DashboardCard(
      title: title,
      value: "Manage",
      icon: icon,
      gradient: gradient,
      onTap: onTap,
      showArrow: true,
    );
  }
}
