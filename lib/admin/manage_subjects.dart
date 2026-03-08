import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class ManageSubjectsScreen extends StatefulWidget {
  final String departmentName;
  final String courseName;

  const ManageSubjectsScreen({
    super.key,
    required this.departmentName,
    required this.courseName,
  });

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final subjectController = TextEditingController();
  final List<String> semesters = List.generate(8, (i) => 'Semester ${i + 1}');
  String _selectedSemester = 'Semester 1';
  bool loading = false;

  Future<void> addSubject() async {
    final name = subjectController.text.trim();
    if (name.isEmpty) return;

    setState(() => loading = true);
    try {
      await FirebaseFirestore.instance.collection('subjects').add({
        'name': name,
        'department': widget.departmentName,
        'course': widget.courseName,
        'semester': _selectedSemester,
        'createdAt': Timestamp.now(),
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Connection timeout. Please check your internet.");
      });
      subjectController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Subject added successfully"),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(
        title: '${widget.courseName} Subjects',
        subtitle: 'Manage subjects in this course',
        showBackButton: true,
        gradient: AppGradients.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
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
                              value: _selectedSemester,
                              items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSemester = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                       Expanded(
                        child: TextField(
                          controller: subjectController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Enter subject name (e.g. Data Structures)",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      loading 
                        ? const CircularProgressIndicator()
                        : FloatingActionButton(
                            onPressed: addSubject,
                            backgroundColor: AppTheme.primaryColor,
                            child: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('subjects')
                    .where('course', isEqualTo: widget.courseName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading subjects: ${snapshot.error}",
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No subjects added yet",
                        style: GoogleFonts.inter(color: Colors.white38),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    
                    final semA = dataA['semester'] as String? ?? 'Semester 1';
                    final semB = dataB['semester'] as String? ?? 'Semester 1';
                    final semComp = semA.compareTo(semB);
                    if (semComp != 0) return semComp;

                    final tA = dataA['createdAt'] as Timestamp?;
                    final tB = dataB['createdAt'] as Timestamp?;
                    if (tA == null && tB == null) return 0;
                    if (tA == null) return 1;
                    if (tB == null) return -1;
                    return tA.compareTo(tB);
                  });

                  final Map<String, List<DocumentSnapshot>> grouped = {};
                  for (final doc in docs) {
                    final sem = (doc.data() as Map<String, dynamic>)['semester'] as String? ?? 'Semester 1';
                    grouped.putIfAbsent(sem, () => []).add(doc);
                  }

                  return ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final semester = grouped.keys.elementAt(index);
                      final subjects = grouped[semester]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                            child: Text(
                              semester,
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...subjects.map((doc) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.03)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                doc['name'],
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                    onPressed: () => _editSubject(context, doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(context, doc),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _editSubject(BuildContext context, DocumentSnapshot doc) async {
    final editController = TextEditingController(text: doc['name']);
    String currentSemester = (doc.data() as Map<String, dynamic>)['semester'] as String? ?? 'Semester 1';
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        String tempSemester = currentSemester;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppTheme.darkSurface,
            title: const Text("Edit Subject", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: AppTheme.darkSurface,
                      isExpanded: true,
                      value: tempSemester,
                      items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => tempSemester = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Subject Name",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () => Navigator.pop(ctx, {'name': editController.text.trim(), 'semester': tempSemester}),
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      final newName = result['name'];
      final newSem = result['semester'];
      if (newName != null && newName.isNotEmpty) {
        await doc.reference.update({
          'name': newName,
          'semester': newSem,
        });
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text("Delete Subject", style: TextStyle(color: Colors.white)),
        content: Text("Remove ${doc['name']}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await doc.reference.delete();
    }
  }
}
