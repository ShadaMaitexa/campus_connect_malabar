import 'package:campus_connect_malabar/services/attendence_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class StudentAttendance extends StatefulWidget {
  const StudentAttendance({super.key});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  final service = AttendanceService();
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  void loadAttendance() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final result = await service.getAttendance(uid);
    setState(() => data = result);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No attendance data")),
      );
    }

    final total = data!['totalClasses'];
    final attended = data!['attendedClasses'];
    final percent = ((attended / total) * 100).toStringAsFixed(1);
    final suggestion = service.getAiSuggestion(total, attended);

    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Attendance: $percent%",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("AI Suggestion:",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(suggestion),
          ],
        ),
      ),
    );
  }
}
