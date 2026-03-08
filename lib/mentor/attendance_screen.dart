import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Selections
  String? _selectedDepartment;
  String? _selectedCourse;
  String? _selectedSemester;
  DateTime _selectedDate = DateTime.now();

  // Available options
  List<String> _departments = [];
  List<String> _courses = [];
  final List<String> _semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  Map<String, String> _timetable = {};
  
  bool _isLoadingInit = true;
  bool _isLoadingTimetable = false;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('departments').orderBy('name').get();
      if (mounted) {
        setState(() {
          _departments = snap.docs.map((d) => d['name'] as String).toList();
          _isLoadingInit = false;
        });
        
        // Auto-select mentor's department if they have one
        _loadMentorDefaults();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingInit = false);
    }
  }

  Future<void> _loadMentorDefaults() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final dept = doc.data()?['department'] as String?;
        if (dept != null && _departments.contains(dept)) {
          setState(() => _selectedDepartment = dept);
          await _fetchCourses(dept);
        }
      }
    } catch (e) {
      debugPrint("Error loading mentor defaults: $e");
    }
  }

  Future<void> _fetchCourses(String dept) async {
    setState(() {
      _courses = [];
      _selectedCourse = null;
      _selectedSemester = null;
      _timetable = {};
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('courses')
          .where('department', isEqualTo: dept)
          .get();
      if (mounted) {
        setState(() {
          _courses = snap.docs.map((d) => d['name'] as String).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
  }

  Future<void> _loadTimetable() async {
    if (_selectedDepartment == null || _selectedCourse == null || _selectedSemester == null) return;
    
    // Check if weekend
    if (_selectedDate.weekday == DateTime.saturday || _selectedDate.weekday == DateTime.sunday) {
      setState(() {
        _timetable = {};
      });
      return; // It's a holiday
    }

    setState(() => _isLoadingTimetable = true);
    
    final dayName = DateFormat('EEEE').format(_selectedDate); // e.g., 'Monday'
    final docId = '${_selectedDepartment}_${_selectedCourse}_${_selectedSemester}_$dayName';
    
    try {
      final doc = await FirebaseFirestore.instance.collection('timetables').doc(docId).get();
      if (mounted) {
        setState(() {
          if (doc.exists) {
            final data = doc.data()!;
            _timetable = {
              'P1': data['P1'] ?? '',
              'P2': data['P2'] ?? '',
              'P3': data['P3'] ?? '',
              'P4': data['P4'] ?? '',
              'P5': data['P5'] ?? '',
            };
          } else {
            _timetable = {};
          }
          _isLoadingTimetable = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading timetable: $e");
      if (mounted) setState(() => _isLoadingTimetable = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTimetable();
    }
  }

  Future<void> _markAttendance(String studentId, String period, bool isPresent) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final docId = '${dateStr}_${_selectedDepartment}_${_selectedCourse}_${_selectedSemester}';
    
    try {
      await FirebaseFirestore.instance.collection('attendance').doc(docId).set({
        studentId: {
          period: isPresent,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error marking attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInit) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWeekend = _selectedDate.weekday == DateTime.saturday || _selectedDate.weekday == DateTime.sunday;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final docId = '${dateStr}_${_selectedDepartment}_${_selectedCourse}_${_selectedSemester}';

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: const CustomAppBar(
          title: "Manage Attendance",
          subtitle: "Auto-synced with Timetable",
          gradient: AppGradients.blue,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSelectionFilters(),
                    if (isWeekend) _buildHolidayState(),
                    if (!isWeekend && _selectedCourse != null && _timetable.isEmpty && !_isLoadingTimetable)
                      _buildNoTimetableState(),
                  ],
                ),
              ),
            ),
            if (!isWeekend && _selectedCourse != null && _timetable.isNotEmpty)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('attendance').doc(docId).snapshots(),
                builder: (context, attendanceSnap) {
                  final Map<dynamic, dynamic> attendanceData = attendanceSnap.hasData && attendanceSnap.data!.exists
                      ? attendanceSnap.data!.data() as Map<dynamic, dynamic>
                      : {};

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'student')
                        .where('department', isEqualTo: _selectedDepartment)
                        .where('course', isEqualTo: _selectedCourse)
                        .where('semester', isEqualTo: _selectedSemester)
                        .snapshots(),
                    builder: (context, studentSnap) {
                      if (!studentSnap.hasData) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (studentSnap.data!.docs.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text("No students found in this course.", style: TextStyle(color: Colors.white54)),
                            ),
                          ),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: _buildAttendanceTable(studentSnap.data!.docs, attendanceData),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildDropdown(
            label: "Department",
            value: _selectedDepartment,
            items: _departments,
            onChanged: (val) {
              setState(() => _selectedDepartment = val);
              if (val != null) _fetchCourses(val);
            },
          ),
          _buildDropdown(
            label: "Course",
            value: _selectedCourse,
            items: _courses,
            enabled: _selectedDepartment != null,
            onChanged: (val) {
              setState(() {
                _selectedCourse = val;
                _selectedSemester = null;
              });
            },
          ),
          _buildDropdown(
            label: "Semester",
            value: _selectedSemester,
            items: _semesters,
            enabled: _selectedCourse != null,
            onChanged: (val) {
              setState(() => _selectedSemester = val);
              if (val != null) _loadTimetable();
            },
          ),
          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: AppTheme.darkSurface,
                isExpanded: true,
                value: value,
                hint: Text("Select", style: TextStyle(color: Colors.white38, fontSize: 14)),
                items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayState() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.beach_access_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            "Holiday – Attendance not required",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Today is a ${DateFormat('EEEE').format(_selectedDate)}. Enjoy the weekend!",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTimetableState() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No Timetable Configured",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "There is no timetable configured for ${DateFormat('EEEE').format(_selectedDate)}s in this course.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable(List<QueryDocumentSnapshot> students, Map<dynamic, dynamic> attendanceData) {
    // Only show columns for periods that actually have a subject assigned
    final activePeriods = ['P1', 'P2', 'P3', 'P4', 'P5'].where((p) => _timetable[p] != null && _timetable[p]!.isNotEmpty).toList();

    if (activePeriods.isEmpty) return _buildNoTimetableState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
            dataRowMaxHeight: 60,
            dataRowMinHeight: 60,
            columnSpacing: 30,
            columns: [
              DataColumn(label: Text('Student Name', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white))),
              ...activePeriods.map((p) => DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(p, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                    Text(_timetable[p] ?? '', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              )),
            ],
            rows: students.map((doc) {
              final studentId = doc.id;
              final studentName = doc['name'] as String;
              
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(studentName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Text(studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  ...activePeriods.map((p) {
                    final studentRecord = attendanceData[studentId] as Map<String, dynamic>?;
                    final isPresent = studentRecord?[p] as bool? ?? false;
                    
                    return DataCell(
                      Center(
                        child: Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: isPresent,
                            activeColor: AppTheme.successColor,
                            checkColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              if (val != null) {
                                _markAttendance(studentId, p, val);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
