import 'package:campus_connect_malabar/services/attendence_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AttendanceProgressCard extends StatelessWidget {
  AttendanceProgressCard({super.key});

  final AttendanceService _attendanceService = AttendanceService();

  @override
  Widget build(BuildContext context) {
    final String studentId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _attendanceService.getAttendance(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Attendance data not available"),
          );
        }

        final int totalClasses = snapshot.data!['totalClasses'];
        final int attendedClasses = snapshot.data!['attendedClasses'];

        final double percentage =
            (attendedClasses / totalClasses * 100).clamp(0, 100);

        final String aiSuggestion =
            _attendanceService.getAiSuggestion(
                totalClasses, attendedClasses);

        /// Prediction for 75%
        int requiredFor75 =
            ((0.75 * totalClasses) - attendedClasses).ceil();
        if (requiredFor75 < 0) requiredFor75 = 0;

        Color progressColor;
        if (percentage >= 80) {
          progressColor = Colors.green;
        } else if (percentage >= 75) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.red;
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Attendance Progress",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  color: progressColor,
                  borderRadius: BorderRadius.circular(10),
                ),

                const SizedBox(height: 8),

                Text(
                  "${percentage.toStringAsFixed(1)}% attendance",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: progressColor),
                ),

                const SizedBox(height: 6),

                Text("🤖 AI Insight: $aiSuggestion"),

                if (percentage < 75)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Attend $requiredFor75 more classes to reach 75% (Exam Eligible)",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
