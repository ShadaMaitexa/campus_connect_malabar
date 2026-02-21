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

    // 2️⃣ Send email to the approved user
    await EmailService.sendApprovalEmail(
      userName: name,
      userEmail: email,
      role: role,
    );
  }

  /// Reject any user
  static Future<void> rejectUser({
    required String userId,
    required String role,
    required String name,
    required String email,
  }) async {
    // 1️⃣ Delete from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete();

    // 2️⃣ Could potentially send rejection email here if EmailService supports it, but for now just delete.
  }
}
