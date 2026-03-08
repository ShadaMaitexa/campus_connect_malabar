import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _selectedPeriod;
  DateTime _selectedDate = DateTime.now();

  // Available options
  List<String> _departments = [];
  List<String> _courses = [];
  final List<String> _semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  final List<String> _periods = ['Period 1', 'Period 2', 'Period 3', 'Period 4', 'Period 5'];
  List<Map<String, dynamic>> _availableSubjects = [];
  String? _selectedSubjectId;
  
  bool _isLoadingInit = true;
  bool _isLoadingSubjects = false;
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchDepartments();
    await _loadPersistentSelections();
    
    // If no persistent department, use mentor default
    if (_selectedDepartment == null) {
      await _loadMentorDefaults();
    }
  }

  Future<void> _saveSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_selectedDepartment != null) await prefs.setString('attendance_dept', _selectedDepartment!);
      if (_selectedCourse != null) await prefs.setString('attendance_course', _selectedCourse!);
      if (_selectedSemester != null) await prefs.setString('attendance_semester', _selectedSemester!);
      if (_selectedPeriod != null) await prefs.setString('attendance_period', _selectedPeriod!);
      if (_selectedSubjectId != null) await prefs.setString('attendance_subject_id', _selectedSubjectId!);
    } catch (e) {
      debugPrint("Error saving selections: $e");
    }
  }

  Future<void> _loadPersistentSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dept = prefs.getString('attendance_dept');
      final course = prefs.getString('attendance_course');
      final semester = prefs.getString('attendance_semester');
      final period = prefs.getString('attendance_period');
      final subjectId = prefs.getString('attendance_subject_id');

      if (mounted) {
        setState(() {
          if (dept != null && _departments.contains(dept)) {
            _selectedDepartment = dept;
          }
          if (course != null) {
            _selectedCourse = course;
          }
          if (semester != null) {
            _selectedSemester = semester;
          }
          if (period != null) {
            _selectedPeriod = period;
          }
          if (subjectId != null) {
            _selectedSubjectId = subjectId;
          }
        });

        if (_selectedDepartment != null) {
          await _fetchCourses(_selectedDepartment!);
          if (_selectedCourse != null && _courses.contains(_selectedCourse)) {
            // Course is already set by setState, but we need to fetch subjects if semester is also set
            if (_selectedSemester != null) {
              await _fetchSubjects();
            }
          } else {
             // Reset course if it's not in the newly fetched courses for the department
             setState(() => _selectedCourse = null);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading persistent selections: $e");
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('departments').orderBy('name').get();
      if (mounted) {
        setState(() {
          _departments = snap.docs.map((d) => d['name'] as String).toList();
          _isLoadingInit = false;
        });
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
      // Do not reset _selectedCourse here if we are loading from persistence
      _availableSubjects = [];
      _isLoadingSubjects = false;
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

  Future<void> _fetchSubjects() async {
    if (_selectedDepartment == null || _selectedCourse == null || _selectedSemester == null) return;
    
    setState(() {
      _isLoadingSubjects = true;
      _availableSubjects = [];
    });
    
    try {
      final snap = await FirebaseFirestore.instance
          .collection('subjects')
          .where('department', isEqualTo: _selectedDepartment)
          .where('course', isEqualTo: _selectedCourse)
          .where('semester', isEqualTo: _selectedSemester)
          .get();
          
      if (mounted) {
        setState(() {
          _availableSubjects = snap.docs.map((doc) => {
            'id': doc.id,
            'name': doc['name'],
          }).toList();
          _isLoadingSubjects = false;
          
          // Auto-select first subject if only one, or validate current selection
          if (_selectedSubjectId != null) {
            final exists = _availableSubjects.any((s) => s['id'] == _selectedSubjectId);
            if (!exists) {
              _selectedSubjectId = null;
              _selectedPeriod = null;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
      if (mounted) setState(() => _isLoadingSubjects = false);
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
    }
  }

  Future<void> _markAttendance(String studentId, String studentName, String subjectId, String subjectName, String semester, bool isPresent) async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a period first")),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final docId = '${dateStr}_${studentId}_${subjectId}_${_selectedPeriod}';
    
    try {
      await FirebaseFirestore.instance.collection('attendance_records').doc(docId).set({
        'department': _selectedDepartment,
        'course': _selectedCourse,
        'semester': semester,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'period': _selectedPeriod,
        'date': dateStr,
        'studentId': studentId,
        'studentName': studentName,
        'status': isPresent ? 'Present' : 'Absent',
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: const CustomAppBar(
          title: "Manage Attendance",
          subtitle: "Single-subject selection mode",
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
                    if (_selectedSemester != null && _availableSubjects.isEmpty && !_isLoadingSubjects)
                      _buildNoSubjectsState(),
                    if (_availableSubjects.isNotEmpty)
                      _buildSubjectSelection(),
                    if (_selectedSubjectId != null)
                      _buildPeriodSelection(),
                  ],
                ),
              ),
            ),
            if (_selectedSubjectId != null && _selectedPeriod != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendance_records')
                    .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate))
                    .where('department', isEqualTo: _selectedDepartment)
                    .where('course', isEqualTo: _selectedCourse)
                    .where('semester', isEqualTo: _selectedSemester)
                    .where('subjectId', isEqualTo: _selectedSubjectId)
                    .where('period', isEqualTo: _selectedPeriod)
                    .snapshots(),
                builder: (context, attendanceSnap) {
                  final Map<String, String> attendanceData = {};
                  if (attendanceSnap.hasData) {
                    for (var doc in attendanceSnap.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final sId = data['studentId'];
                      final status = data['status'] as String;
                      attendanceData[sId] = status;
                    }
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'student')
                        .where('department', isEqualTo: _selectedDepartment)
                        .where('course', isEqualTo: _selectedCourse)
                        .where('semester', isEqualTo: _selectedSemester)
                        .snapshots(),
                    builder: (context, studentSnap) {
                      if (studentSnap.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          )),
                        );
                      }

                      if (studentSnap.data!.docs.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text("No students found for the selected semester.", style: TextStyle(color: Colors.white54)),
                            ),
                          ),
                        );
                      }

                      final students = studentSnap.data!.docs;

                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (attendanceData.isNotEmpty)
                              _buildAlreadyMarkedBanner(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                              child: Text(
                                _selectedSemester!,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildAttendanceTable(students, attendanceData, _selectedSemester!),
                          ],
                        ),
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
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildDropdown(
                label: "Department",
                value: _selectedDepartment,
                items: _departments,
                onChanged: (val) {
                  setState(() {
                    _selectedDepartment = val;
                    _selectedCourse = null;
                    _selectedSemester = null;
                    _selectedPeriod = null;
                    _selectedSubjectId = null;
                  });
                  if (val != null) _fetchCourses(val);
                  _saveSelections();
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
                    _selectedPeriod = null;
                    _selectedSubjectId = null;
                  });
                  _saveSelections();
                },
              ),
              _buildDatePicker(),
            ],
          ),
          if (_selectedCourse != null) ...[
            const SizedBox(height: 20),
            _buildSemesterSelection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSemesterSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Semester", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _semesters.map((sem) {
            final isSelected = _selectedSemester == sem;
            return ChoiceChip(
              label: Text(sem, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSemester = sem;
                    _selectedPeriod = null;
                    _selectedSubjectId = null;
                    _availableSubjects = [];
                  });
                  _fetchSubjects();
                  _saveSelections();
                }
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectSelection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Subject", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSubjects.map((subject) {
              final isSelected = _selectedSubjectId == subject['id'];
              return ChoiceChip(
                label: Text(subject['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSubjectId = subject['id'];
                      _selectedPeriod = null;
                    });
                    _saveSelections();
                  }
                },
                selectedColor: AppTheme.primaryColor,
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Period", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return ChoiceChip(
                label: Text(period, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    _saveSelections();
                  }
                },
                selectedColor: AppTheme.primaryColor,
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubjectsState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "No subjects available for the selected semester.",
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
          ),
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

  Widget _buildAttendanceTable(List<QueryDocumentSnapshot> students, Map<String, String> attendanceData, String semester) {
    if (_selectedSubjectId == null) return const SizedBox.shrink();

    final subName = _availableSubjects.firstWhere((s) => s['id'] == _selectedSubjectId, orElse: () => {'name': 'Unknown'})['name'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
            dataRowMaxHeight: 70,
            dataRowMinHeight: 70,
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text('Student Name', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white))),
              DataColumn(label: Text('Attendance Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
            rows: students.map((doc) {
              final studentId = doc.id;
              final studentName = doc['name'] as String;
              final status = attendanceData[studentId];
              
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            Text(studentId, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        _buildStatusButton(
                          label: "Present",
                          isActive: status == 'Present',
                          activeColor: AppTheme.successColor,
                          onPressed: () => _markAttendance(studentId, studentName, _selectedSubjectId!, subName, semester, true),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusButton(
                          label: "Absent",
                          isActive: status == 'Absent',
                          activeColor: Colors.redAccent,
                          onPressed: () => _markAttendance(studentId, studentName, _selectedSubjectId!, subName, semester, false),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyMarkedBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.successColor, size: 20),
          const SizedBox(width: 12),
          Text(
            "Attendance already marked for this period.",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? activeColor : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
