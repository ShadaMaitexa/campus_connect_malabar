import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../widgets/loading_shimmer.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: 'My Attendance',
          subtitle: 'Daily Progress Tracker',
          gradient: AppGradients.blue,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // 1. Overall Summary Section
                AppAnimations.slideInFromBottom(
                  delay: const Duration(milliseconds: 100),
                  child: _buildAttendanceSummary(uid),
                ),

                const SizedBox(height: 12),

                // 2. Today's Status Section
                _buildTodayStatusSection(uid),

                const SizedBox(height: 24),

                // 3. Information Section (To make it feel less empty)
                AppAnimations.slideInFromBottom(
                  delay: const Duration(milliseconds: 400),
                  child: _buildAttendanceInsights(),
                ),

                const SizedBox(height: 80), // Padding for bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatusSection(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        bool hasData =
            snapshot.hasData &&
            snapshot.data!.exists &&
            (snapshot.data!.data() as Map<String, dynamic>).containsKey(uid);

        if (!hasData) {
          return AppAnimations.slideInFromBottom(
            delay: const Duration(milliseconds: 300),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: EmptyStateWidget(
                icon: Icons.event_note_rounded,
                title: "Not Marked Yet",
                subtitle: "Checking back later for today's status",
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final present = data[uid]['present'] as bool;

        return Column(
          children: [
            AppAnimations.scaleIn(
              child: _AttendanceStatusCard(present: present),
              duration: const Duration(milliseconds: 600),
            ),
            const SizedBox(height: 24),
            AppAnimations.slideInFromBottom(
              delay: const Duration(milliseconds: 300),
              child: _AttendanceInfo(date: DateTime.now(), present: present),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attendance Insights",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up_rounded,
              "Consistent Attendance",
              "Maintain above 75% for exam eligibility.",
              AppTheme.successColor,
            ),
            const Divider(color: AppTheme.darkBorder, height: 24),
            _buildInsightItem(
              Icons.warning_amber_rounded,
              "Minimum Criteria",
              "A drop below 60% may require special permission.",
              AppTheme.warningColor,
            ),
            const Divider(color: AppTheme.darkBorder, height: 24),
            _buildInsightItem(
              Icons.info_outline_rounded,
              "Marking Process",
              "Attendance is usually updated within 2 hours of class.",
              AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance_summary')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerCard(height: 100),
          );
        }

        final data = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : {'present': 0, 'total': 0};

        final present = data['present'] ?? 0;
        final total = data['total'] ?? 0;
        final percentage = total > 0 ? (present / total) * 100 : 0.0;

        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${percentage.toInt()}%',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester Status',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Overall Persistence',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatMini(label: 'Present', val: '$present'),
                        const SizedBox(width: 12),
                        _StatMini(label: 'Total', val: '$total'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String val;
  const _StatMini({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
        ),
      ],
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  final bool present;

  const _AttendanceStatusCard({required this.present});

  @override
  Widget build(BuildContext context) {
    final gradient = present ? AppGradients.success : AppGradients.danger;
    final icon = present ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final status = present ? 'PRESENT' : 'ABSENT';
    final message = present
        ? 'You were marked present today'
        : 'You were marked absent today';

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAnimations.pulse(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AttendanceInfo extends StatelessWidget {
  final DateTime date;
  final bool present;

  const _AttendanceInfo({required this.date, required this.present});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: '${date.day}/${date.month}/${date.year}',
            ),
            const Divider(color: AppTheme.darkBorder, height: 24),
            _InfoRow(
              icon: present ? Icons.check_circle_outline : Icons.highlight_off,
              label: 'Status',
              value: present ? 'Present' : 'Absent',
              valueColor: present ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}
