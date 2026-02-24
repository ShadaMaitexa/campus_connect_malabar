import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ─────────────────────────────────────────────
//  Student Reports List Screen
// ─────────────────────────────────────────────
class StudentReportsScreen extends StatefulWidget {
  const StudentReportsScreen({super.key});

  @override
  State<StudentReportsScreen> createState() => _StudentReportsScreenState();
}

class _StudentReportsScreenState extends State<StudentReportsScreen> {
  String? _department;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDept();
  }

  Future<void> _loadDept() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _department = doc.data()?['department'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: 'Student Reports',
          subtitle: _department ?? 'General',
          gradient: AppGradients.primary,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.06),
                AppTheme.darkBackground,
              ],
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'student')
                .where('department', isEqualTo: _department)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final students = snapshot.data?.docs ?? [];

              if (students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group_off_rounded,
                          size: 56,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No students found',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No students in your department yet',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final data = student.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Student';
                  final email = data['email'] ?? '';
                  final semester = data['semester'] ?? '';

                  return _StudentCard(
                    name: name,
                    email: email,
                    semester: semester.toString(),
                    initials: name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailReportScreen(
                          studentId: student.id,
                          studentName: name,
                          department: _department ?? '',
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String semester;
  final String initials;
  final VoidCallback onTap;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.semester,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with gradient
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (semester.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sem $semester',
                        style: GoogleFonts.robotoMono(
                          color: AppTheme.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Student Detail Report + Internal Marks Screen
// ─────────────────────────────────────────────
class StudentDetailReportScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String department;

  const StudentDetailReportScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.department,
  });

  @override
  State<StudentDetailReportScreen> createState() =>
      _StudentDetailReportScreenState();
}

class _StudentDetailReportScreenState extends State<StudentDetailReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMarksTab = false;

  // Key to access the marks tab state for the FAB dialog
  final GlobalKey<_InternalMarksTabState> _marksTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _isMarksTab = _tabController.index == 1);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: widget.studentName,
          subtitle: 'Student Report Panel',
          showBackButton: true,
          gradient: AppGradients.primary,
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isMarksTab
              ? FloatingActionButton.extended(
                  key: const ValueKey('fab_marks'),
                  onPressed: () =>
                      _marksTabKey.currentState?._showAddMarksDialog(),
                  backgroundColor: AppTheme.primaryColor,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'Add Marks',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('fab_empty')),
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.darkSurface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.white38,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.bar_chart_rounded, size: 20),
                    text: 'Attendance',
                  ),
                  Tab(
                    icon: Icon(Icons.edit_note_rounded, size: 20),
                    text: 'Internal Marks',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AttendanceSummaryTab(studentId: widget.studentId),
                  _InternalMarksTab(
                    key: _marksTabKey,
                    studentId: widget.studentId,
                    studentName: widget.studentName,
                    department: widget.department,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Attendance Summary Tab
// ─────────────────────────────────────────────
class _AttendanceSummaryTab extends StatelessWidget {
  final String studentId;
  const _AttendanceSummaryTab({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance_summary')
          .doc(studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : {'present': 0, 'total': 0};

        final present = (data['present'] ?? 0) as int;
        final total = (data['total'] ?? 0) as int;
        final percentage = total > 0 ? (present / total) * 100 : 0.0;

        Color statusColor = percentage >= 75
            ? AppTheme.successColor
            : percentage >= 60
            ? AppTheme.warningColor
            : AppTheme.errorColor;

        String statusText = percentage >= 75
            ? 'Eligible'
            : percentage >= 60
            ? 'At Risk'
            : 'Detained';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Big Circular Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Overall Attendance',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Present',
                      value: '$present',
                      color: AppTheme.successColor,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Absent',
                      value: '${total - present}',
                      color: AppTheme.errorColor,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Total Days',
                      value: '$total',
                      color: AppTheme.accentColor,
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Eligibility bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exam Eligibility Status',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}% attendance',
                          style: GoogleFonts.inter(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Min required: 75%',
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Internal Marks Tab
// ─────────────────────────────────────────────
class _InternalMarksTab extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String department;

  const _InternalMarksTab({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.department,
  });

  @override
  State<_InternalMarksTab> createState() => _InternalMarksTabState();
}

class _InternalMarksTabState extends State<_InternalMarksTab> {
  final List<String> semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  String _selectedSemester = 'Semester 1';

  void _showAddMarksDialog() {
    final subjectController = TextEditingController();
    final marksController = TextEditingController();
    final maxMarksController = TextEditingController(text: '50');
    String selectedSem = _selectedSemester;
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => Dialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Internal Marks',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.studentName,
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Semester Dropdown
                Text(
                  'Semester',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSem,
                      isExpanded: true,
                      dropdownColor: AppTheme.darkSurfaceSecondary,
                      style: GoogleFonts.inter(color: Colors.white),
                      items: semesters
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDState(() => selectedSem = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subject Field
                Text(
                  'Subject Name',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                _MarkField(
                  controller: subjectController,
                  hint: 'e.g. Data Structures',
                  icon: Icons.book_outlined,
                ),
                const SizedBox(height: 16),

                // Marks Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marks Obtained',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _MarkField(
                            controller: marksController,
                            hint: '0',
                            icon: Icons.grade_rounded,
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Max Marks',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _MarkField(
                            controller: maxMarksController,
                            hint: '50',
                            icon: Icons.score_rounded,
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.darkBorder),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final subject = subjectController.text.trim();
                                  final marks =
                                      int.tryParse(marksController.text) ?? 0;
                                  final maxMarks =
                                      int.tryParse(maxMarksController.text) ??
                                      50;

                                  if (subject.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a subject name',
                                        ),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  if (marks > maxMarks) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Marks cannot exceed max marks',
                                        ),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  setDState(() => saving = true);
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('internal_marks')
                                        .add({
                                          'studentId': widget.studentId,
                                          'studentName': widget.studentName,
                                          'department': widget.department,
                                          'semester': selectedSem,
                                          'subject': subject,
                                          'marks': marks,
                                          'maxMarks': maxMarks,
                                          'addedBy': FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                          'createdAt': Timestamp.now(),
                                        });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (mounted) {
                                      setState(
                                        () => _selectedSemester = selectedSem,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Marks saved for $subject',
                                          ),
                                          backgroundColor:
                                              AppTheme.successColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setDState(() => saving = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to save marks'),
                                          backgroundColor: AppTheme.errorColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save Marks',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Semester Selector Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.darkSurface,
          child: Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Filter by Semester:',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
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
                          onTap: () => setState(() => _selectedSemester = sem),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppGradients.primary
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

        // Marks List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('internal_marks')
                .where('studentId', isEqualTo: widget.studentId)
                .where('semester', isEqualTo: _selectedSemester)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // Sort client-side by createdAt
              final docs = List.of(snapshot.data?.docs ?? []);
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          size: 52,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No marks added yet',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + to add marks for $_selectedSemester',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
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

              return Column(
                children: [
                  // Summary Banner
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${overallPct.toStringAsFixed(1)}%',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject-wise list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final d = docs[index].data() as Map<String, dynamic>;
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

                        return Dismissible(
                          key: Key(docs[index].id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.4),
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.errorColor,
                            ),
                          ),
                          confirmDismiss: (_) => showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: AppTheme.darkSurface,
                              title: Text(
                                'Delete Entry?',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              content: Text(
                                'Remove marks for "$subject"?',
                                style: GoogleFonts.inter(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (_) async {
                            await docs[index].reference.delete();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: pctColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.book_rounded,
                                        color: pctColor,
                                        size: 18,
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$marks / $maxMarks',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          '${pct.toStringAsFixed(1)}%',
                                          style: GoogleFonts.inter(
                                            color: pctColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct / 100,
                                    backgroundColor: Colors.white12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      pctColor,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Slide left to delete',
                                  style: GoogleFonts.inter(
                                    color: Colors.white24,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable input widget for the dialog
// ─────────────────────────────────────────────
class _MarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isNumber;

  const _MarkField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        filled: true,
        fillColor: AppTheme.darkSurfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
