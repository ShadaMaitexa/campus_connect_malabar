import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  // Cascading selections
  String? _selectedDepartment;
  String? _selectedCourse;
  String? _selectedSemester;
  String? _selectedDay;

  // Available options
  List<String> _departments = [];
  List<String> _courses = [];
  final List<String> _semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  List<String> _subjects = [];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  // Current timetable state
  final Map<String, String?> _periods = {
    'P1': null,
    'P2': null,
    'P3': null,
    'P4': null,
    'P5': null,
  };

  bool _isLoading = true;
  bool _isSaving = false;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching departments: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCourses(String dept) async {
    setState(() {
      _courses = [];
      _selectedCourse = null;
      _subjects = [];
      _resetPeriods();
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

  Future<void> _fetchSubjectsAndTimetable() async {
    if (_selectedDepartment == null || _selectedCourse == null || _selectedSemester == null) return;
    
    setState(() {
      _subjects = [];
      _resetPeriods();
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
          _subjects = snap.docs.map((d) => d['name'] as String).toList();
        });
      }
      if (_selectedDay != null) {
        await _loadTimetable();
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    }
  }

  void _resetPeriods() {
    for (var i = 1; i <= 5; i++) {
      _periods['P$i'] = null;
    }
  }

  Future<void> _loadTimetable() async {
    if (_selectedDepartment == null || _selectedCourse == null || _selectedSemester == null || _selectedDay == null) return;
    
    setState(() => _isLoading = true);
    final docId = '${_selectedDepartment}_${_selectedCourse}_${_selectedSemester}_${_selectedDay}';
    
    try {
      final doc = await FirebaseFirestore.instance.collection('timetables').doc(docId).get();
      if (mounted) {
        setState(() {
          if (doc.exists) {
            final data = doc.data()!;
            for (var i = 1; i <= 5; i++) {
              final val = data['P$i'] as String?;
              _periods['P$i'] = (_subjects.contains(val)) ? val : null;
            }
          } else {
             _resetPeriods();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading timetable: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTimetable() async {
    if (_selectedDepartment == null || _selectedCourse == null || _selectedSemester == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Department, Course, Semester, and Day.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final docId = '${_selectedDepartment}_${_selectedCourse}_${_selectedSemester}_${_selectedDay}';

    try {
      await FirebaseFirestore.instance.collection('timetables').doc(docId).set({
        'department': _selectedDepartment,
        'course': _selectedCourse,
        'semester': _selectedSemester,
        'day': _selectedDay,
        'P1': _periods['P1'] ?? '',
        'P2': _periods['P2'] ?? '',
        'P3': _periods['P3'] ?? '',
        'P4': _periods['P4'] ?? '',
        'P5': _periods['P5'] ?? '',
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Timetable saved successfully!"),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Manage Timetables",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading && _departments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionRow(),
                  const SizedBox(height: 32),
                  if (_selectedDepartment != null && _selectedCourse != null && _selectedSemester != null && _selectedDay != null)
                    _buildTimetableEditor()
                  else
                    _buildEmptyState(),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectionRow() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
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
              setState(() {
                _selectedDepartment = val;
                _selectedCourse = null;
                _selectedSemester = null;
                _selectedDay = null;
                _courses = [];
                _subjects = [];
                _resetPeriods();
              });
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
                _selectedDay = null;
                _subjects = [];
                _resetPeriods();
              });
            },
          ),
          _buildDropdown(
            label: "Semester",
            value: _selectedSemester,
            items: _semesters,
            enabled: _selectedCourse != null,
            onChanged: (val) {
              setState(() {
                _selectedSemester = val;
                _selectedDay = null;
                _resetPeriods();
              });
              if (val != null) _fetchSubjectsAndTimetable();
            },
          ),
          _buildDropdown(
            label: "Day",
            value: _selectedDay,
            items: _days,
            enabled: _selectedSemester != null,
            onChanged: (val) {
              setState(() => _selectedDay = val);
              if (val != null) _loadTimetable();
            },
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
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: AppTheme.darkSurface,
                isExpanded: true,
                value: value,
                hint: Text("Select $label", style: TextStyle(color: Colors.white38, fontSize: 14)),
                items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableEditor() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Schedule for $_selectedDay",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(5, (index) {
            final p = 'P${index + 1}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p,
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: AppTheme.darkSurface,
                          isExpanded: true,
                          value: _periods[p],
                          hint: const Text("Free Period / No Subject", style: TextStyle(color: Colors.white38, fontSize: 14)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text("Free Period / No Subject", style: TextStyle(color: Colors.white54))),
                            ..._subjects.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white)))),
                          ],
                          onChanged: (val) {
                            setState(() => _periods[p] = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTimetable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Save $_selectedDay Timetable", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            "Select Department, Course, Semester, and Day\nto configure the timetable.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
