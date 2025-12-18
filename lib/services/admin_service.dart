import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> blockAlumni(String userId) async {
    // Delete marketplace posts
    final posts = await _db
        .collection('marketplace')
        .where('postedBy', isEqualTo: userId)
        .get();

    for (var doc in posts.docs) {
      await doc.reference.delete();
    }

    // Delete chats
    final chats = await _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    for (var chat in chats.docs) {
      await chat.reference.delete();
    }

    // Delete user
    await _db.collection('users').doc(userId).delete();
  }
}
