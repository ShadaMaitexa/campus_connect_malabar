import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mentor updates attendance
  Future<void> updateAttendance({
    required String studentId,
    required int totalClasses,
    required int attendedClasses,
  }) async {
    await _db.collection('attendance').doc(studentId).set({
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
    });
  }

  /// Student fetches attendance
  Future<Map<String, dynamic>?> getAttendance(String studentId) async {
    final doc =
        await _db.collection('attendance').doc(studentId).get();
    return doc.exists ? doc.data() : null;
  }

  /// AI suggestion (rule-based)
  String getAiSuggestion(int total, int attended) {
    final percentage = (attended / total) * 100;

    if (percentage >= 75) {
      return "Good attendance 👍 Keep it up!";
    } else if (percentage >= 60) {
      return "Attend next few classes to reach 75%";
    } else {
      return "Low attendance ⚠ Attend all upcoming classes urgently";
    }
  }
}
