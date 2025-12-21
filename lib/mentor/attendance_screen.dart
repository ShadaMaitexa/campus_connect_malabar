import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../widgets/loading_shimmer.dart';

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

  if (!doc.exists || doc.data() == null) {
    throw Exception("Mentor profile not found");
  }

  final data = doc.data()!;

  if (data['role'] != 'mentor') {
    throw Exception("Logged user is not mentor");
  }

  if (!data.containsKey('department')) {
    throw Exception("Mentor department missing");
  }

  department = data['department'];
  setState(() => loading = false);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: CustomAppBar(
        title: "Attendance",
        subtitle: department,
        gradient: AppGradients.blue,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
    .collection('users')
    .where('role', isEqualTo: 'student')
    .where('department', isEqualTo: department)
    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.group_off,
                      title: "No students found",
                      subtitle: "No students are registered in this department",
                    );
                  }

                  return AppAnimations.staggeredList(
                    children: snapshot.data!.docs
                        .map((doc) => _studentAttendanceCard(doc))
                        .toList(),
                    staggerDelay: const Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          ),
        ],
      ),    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No students found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- STUDENT CARD ----------------
  Widget _studentAttendanceCard(QueryDocumentSnapshot doc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF4B6CB7).withOpacity(0.15),
            child: Text(
              doc['name'][0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF4B6CB7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Text(
              doc['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          Switch(
            value: true,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            onChanged: (value) {
              markAttendance(doc.id, value);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? "Marked ${doc['name']} as PRESENT"
                        : "Marked ${doc['name']} as ABSENT",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
