import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String department;
  bool loading = true;
  final String today = DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    loadMentorDepartment();
  }

  Future<void> loadMentorDepartment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted && doc.exists) {
      department = doc.data()?['department'] ?? 'General';
      setState(() => loading = false);
    }
  }

  Future<void> markAttendance(String studentId, bool present) async {
    await FirebaseFirestore.instance.collection('attendance').doc(today).set({
      studentId: {
        'present': present,
        'markedBy': FirebaseAuth.instance.currentUser!.uid,
        'department': department,
        'timestamp': Timestamp.now(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(
        title: "Attendance",
        subtitle: "$department | $today",
        gradient: AppGradients.blue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .doc(today)
            .snapshots(),
        builder: (context, attendanceSnap) {
          final attendanceData =
              attendanceSnap.hasData && attendanceSnap.data!.exists
              ? attendanceSnap.data!.data() as Map<String, dynamic>
              : {};

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Auto-save Indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Attendance is automatically saved upon change.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .where('department', isEqualTo: department)
                      .snapshots(),
                  builder: (context, studentSnap) {
                    if (!studentSnap.hasData) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (studentSnap.data!.docs.isEmpty) {
                      return SliverToBoxAdapter(child: _emptyState());
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final studentDoc = studentSnap.data!.docs[index];
                        final studentId = studentDoc.id;
                        final isPresent =
                            attendanceData[studentId]?['present'] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _studentAttendanceCard(studentDoc, isPresent),
                        );
                      }, childCount: studentSnap.data!.docs.length),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Icon(Icons.group_off, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "No students found",
            style: TextStyle(fontSize: 16, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _studentAttendanceCard(QueryDocumentSnapshot doc, bool isPresent) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.darkSurface,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
            child: Text(
              doc['name'][0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isPresent ? "Present" : "Absent",
                  style: TextStyle(
                    fontSize: 12,
                    color: isPresent ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPresent,
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.3),
            onChanged: (value) async {
              await markAttendance(doc.id, value);
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: value
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    content: Text(
                      value
                          ? "Marked ${doc['name']} as PRESENT"
                          : "Marked ${doc['name']} as ABSENT",
                      style: const TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
