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

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(
        title: 'My Attendance',
        subtitle: 'Today\'s Status',
        gradient: AppGradients.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppGradients.blue.colors.first.withOpacity(0.05),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('attendance')
              .doc(today())
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading attendance...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData ||
                !snapshot.data!.exists ||
                !(snapshot.data!.data() as Map<String, dynamic>).containsKey(
                  uid,
                )) {
              return const EmptyStateWidget(
                icon: Icons.event_busy_rounded,
                title: "Not Marked Yet",
                subtitle: "Your attendance has not been marked for today",
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final present = data[uid]['present'] as bool;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppAnimations.scaleIn(
                      child: _AttendanceStatusCard(present: present),
                      duration: const Duration(milliseconds: 600),
                    ),
                    const SizedBox(height: 32),
                    AppAnimations.slideInFromBottom(
                      delay: const Duration(milliseconds: 300),
                      child: _AttendanceInfo(
                        date: DateTime.now(),
                        present: present,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAnimations.pulse(
            minScale: 0.95,
            maxScale: 1.05,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(icon, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppGradients.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: _formatDate(date),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Day',
            value: _getDayOfWeek(date),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: present
                ? Icons.check_circle_outline_rounded
                : Icons.highlight_off_rounded,
            label: 'Status',
            value: present ? 'Present' : 'Absent',
            valueColor: present ? AppTheme.successColor : AppTheme.errorColor,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _getDayOfWeek(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
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
