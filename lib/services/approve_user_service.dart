import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/email_service.dart';

class ApproveUserService {
  /// Approve any user
  static Future<void> approveUser({
    required String userId,
    required String role,
    required String name,
    required String email,
  }) async {
    // 1️⃣ Update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'approved': true,
      'approvedAt': Timestamp.now(),
    });

    // 2️⃣ Send email ONLY if mentor
    if (role == 'mentor') {
      await EmailService.sendMentorApprovalEmail(
        mentorName: name,
        mentorEmail: email,
      );
    }
  }
}
