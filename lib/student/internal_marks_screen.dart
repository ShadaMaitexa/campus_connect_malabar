import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class StudentInternalMarksScreen extends StatefulWidget {
  const StudentInternalMarksScreen({super.key});

  @override
  State<StudentInternalMarksScreen> createState() =>
      _StudentInternalMarksScreenState();
}

class _StudentInternalMarksScreenState
    extends State<StudentInternalMarksScreen> {
  final List<String> semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  String _selectedSemester = 'Semester 1';
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: 'Internal Marks',
          subtitle: 'Academic Performance',
          showBackButton: true,
          gradient: AppGradients.purple,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppGradients.purple.colors.first.withOpacity(0.07),
                AppTheme.darkBackground,
              ],
            ),
          ),
          child: Column(
            children: [
              // ── Semester Selector ──
              Container(
                color: AppTheme.darkSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Semester:',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: semesters.map((sem) {
                            final isSelected = _selectedSemester == sem;
                            final label = sem.replaceAll('Semester ', 'S');
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSemester = sem),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppGradients.purple
                                        : null,
                                    color: isSelected
                                        ? null
                                        : AppTheme.darkSurfaceSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : AppTheme.darkBorder,
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: GoogleFonts.robotoMono(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white54,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Marks List ──
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Query only by studentId — filter semester client-side
                  // to avoid a composite Firestore index requirement.
                  stream: FirebaseFirestore.instance
                      .collection('internal_marks')
                      .where('studentId', isEqualTo: _uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Unable to load marks',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                style: GoogleFonts.inter(
                                  color: Colors.red.shade300,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allDocs = List.of(snapshot.data?.docs ?? []);
                    
                    if (allDocs.isNotEmpty) {
                       final availableSemesters = allDocs.map((d) => (d.data() as Map<String, dynamic>)['semester'].toString()).toSet();
                       if (!availableSemesters.contains(_selectedSemester)) {
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                  setState(() => _selectedSemester = availableSemesters.first);
                              }
                           });
                       }
                    }

                    // Filter by semester client-side (avoids composite Firestore index)
                    final docs = allDocs.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return d['semester'] == _selectedSemester;
                    }).toList();

                    // Sort by createdAt client-side
                    docs.sort((a, b) {
                      final aD = a.data() as Map<String, dynamic>;
                      final bD = b.data() as Map<String, dynamic>;
                      final aT = aD['createdAt'];
                      final bT = bD['createdAt'];
                      if (aT == null || bT == null) return 0;
                      return (aT as Timestamp).compareTo(bT as Timestamp);
                    });

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                size: 56,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No marks yet',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your mentor hasn\'t added marks\nfor $_selectedSemester yet.',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Calculate totals
                    int totalObtained = 0;
                    int totalMax = 0;
                    for (final doc in docs) {
                      final d = doc.data() as Map<String, dynamic>;
                      totalObtained += (d['marks'] ?? 0) as int;
                      totalMax += (d['maxMarks'] ?? 0) as int;
                    }
                    final overallPct = totalMax > 0
                        ? (totalObtained / totalMax) * 100
                        : 0.0;

                    final Color summaryColor = overallPct >= 75
                        ? AppTheme.successColor
                        : overallPct >= 50
                        ? AppTheme.warningColor
                        : AppTheme.errorColor;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // ── Summary Banner ──
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppGradients.purple,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppGradients.purple.colors.first
                                    .withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Circular progress
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: overallPct / 100,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.2,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                      strokeWidth: 7,
                                      strokeCap: StrokeCap.round,
                                    ),
                                    Text(
                                      '${overallPct.toStringAsFixed(0)}%',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedSemester,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '$totalObtained / $totalMax',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${docs.length} subject${docs.length != 1 ? 's' : ''} graded',
                                      style: GoogleFonts.inter(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Status Chips Row ──
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryChip(
                                label: 'Obtained',
                                value: '$totalObtained',
                                color: AppTheme.successColor,
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryChip(
                                label: 'Max',
                                value: '$totalMax',
                                color: AppTheme.accentColor,
                                icon: Icons.score_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryChip(
                                label: 'Grade',
                                value: _getGrade(overallPct),
                                color: summaryColor,
                                icon: Icons.emoji_events_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Section Header ──
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                          child: Text(
                            'Subject-wise Breakdown',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // ── Subject Cards ──
                        ...docs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final doc = entry.value;
                          final d = doc.data() as Map<String, dynamic>;
                          final subject = d['subject'] ?? 'Subject';
                          final marks = (d['marks'] ?? 0) as int;
                          final maxMarks = (d['maxMarks'] ?? 50) as int;
                          final pct = maxMarks > 0
                              ? (marks / maxMarks) * 100
                              : 0.0;
                          final Color pctColor = pct >= 75
                              ? AppTheme.successColor
                              : pct >= 50
                              ? AppTheme.warningColor
                              : AppTheme.errorColor;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SubjectCard(
                              rank: idx + 1,
                              subject: subject,
                              marks: marks,
                              maxMarks: maxMarks,
                              pct: pct,
                              pctColor: pctColor,
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGrade(double pct) {
    if (pct >= 90) return 'O';
    if (pct >= 80) return 'A+';
    if (pct >= 70) return 'A';
    if (pct >= 60) return 'B+';
    if (pct >= 50) return 'B';
    if (pct >= 40) return 'C';
    return 'F';
  }
}

// ── Summary Chip ──────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Subject Card ──────────────────────────────
class _SubjectCard extends StatelessWidget {
  final int rank;
  final String subject;
  final int marks;
  final int maxMarks;
  final double pct;
  final Color pctColor;

  const _SubjectCard({
    required this.rank,
    required this.subject,
    required this.marks,
    required this.maxMarks,
    required this.pct,
    required this.pctColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: pctColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: GoogleFonts.robotoMono(
                      color: pctColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$marks/$maxMarks',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pctColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: GoogleFonts.robotoMono(
                        color: pctColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(pctColor),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}
