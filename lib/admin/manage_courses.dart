import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import 'manage_subjects.dart';

class ManageCoursesScreen extends StatefulWidget {
  final String departmentName;

  const ManageCoursesScreen({super.key, required this.departmentName});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final courseController = TextEditingController();
  bool loading = false;

  Future<void> addCourse() async {
    final name = courseController.text.trim();
    if (name.isEmpty) return;

    setState(() => loading = true);
    try {
      await FirebaseFirestore.instance.collection('courses').add({
        'name': name,
        'department': widget.departmentName,
        'createdAt': Timestamp.now(),
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Connection timeout. Please check your internet.");
      });
      courseController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Course added successfully"),
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
        title: '${widget.departmentName} Courses',
        subtitle: 'Manage courses in this department',
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
              child: Row(
                children: [
                   Expanded(
                    child: TextField(
                      controller: courseController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter course name (e.g. BSc CS)",
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
                        onPressed: addCourse,
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(Icons.add_rounded, color: Colors.white),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .where('department', isEqualTo: widget.departmentName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading courses: ${snapshot.error}",
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
                        "No courses added yet",
                        style: GoogleFonts.inter(color: Colors.white38),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final tA = dataA['createdAt'] as Timestamp?;
                    final tB = dataB['createdAt'] as Timestamp?;
                    if (tA == null && tB == null) return 0;
                    if (tA == null) return 1;
                    if (tB == null) return -1;
                    return tB.compareTo(tA);
                  });

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManageSubjectsScreen(
                                  departmentName: widget.departmentName,
                                  courseName: doc['name'],
                                ),
                              ),
                            );
                          },
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
                                onPressed: () => _editCourse(context, doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(context, doc),
                              ),
                            ],
                          ),
                        ),
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

  Future<void> _editCourse(BuildContext context, DocumentSnapshot doc) async {
    final editController = TextEditingController(text: doc['name']);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text("Edit Course", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Course Name",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(ctx, editController.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != doc['name']) {
      await doc.reference.update({'name': newName});
      
      // Also update subjects that belong to this course
      final subjectsQuery = await FirebaseFirestore.instance
          .collection('subjects')
          .where('course', isEqualTo: doc['name'])
          .get();
          
      final batch = FirebaseFirestore.instance.batch();
      for (var subjectDoc in subjectsQuery.docs) {
        batch.update(subjectDoc.reference, {'course': newName});
      }
      await batch.commit();
    }
  }

  Future<void> _confirmDelete(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text("Delete Course", style: TextStyle(color: Colors.white)),
        content: Text("Remove ${doc['name']}? This will also remove any subjects under it.", style: const TextStyle(color: Colors.white70)),
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
      
      // Delete all subjects under this course
      final subjectsQuery = await FirebaseFirestore.instance
          .collection('subjects')
          .where('course', isEqualTo: doc['name'])
          .get();
          
      for (var subjectDoc in subjectsQuery.docs) {
        subjectDoc.reference.delete();
      }
    }
  }
}
