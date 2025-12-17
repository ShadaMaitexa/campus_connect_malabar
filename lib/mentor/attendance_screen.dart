import 'package:campus_connect_malabar/services/attendence_service.dart';
import 'package:flutter/material.dart';


class MentorAttendance extends StatefulWidget {
  const MentorAttendance({super.key});

  @override
  State<MentorAttendance> createState() => _MentorAttendanceState();
}

class _MentorAttendanceState extends State<MentorAttendance> {
  final studentId = TextEditingController();
  final total = TextEditingController();
  final attended = TextEditingController();

  final service = AttendanceService();

  void submit() async {
    await service.updateAttendance(
      studentId: studentId.text,
      totalClasses: int.parse(total.text),
      attendedClasses: int.parse(attended.text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance Updated")),
    );

    studentId.clear();
    total.clear();
    attended.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: studentId,
              decoration: const InputDecoration(labelText: "Student UID"),
            ),
            TextField(
              controller: total,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Classes"),
            ),
            TextField(
              controller: attended,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Attended Classes"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: const Text("Save Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
