import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    required String department,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'approved': role == 'student', // 🔥 only students auto-approved
      'profileCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getDepartments() async {
    final snapshot = await _db.collection('departments').get();
    return snapshot.docs.map((d) => d['name'] as String).toList();
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()!;
  }

  Future<void> saveUser({
    required String uid,
    required String name,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'role': role,
    });
  }

  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc['role'];
  }
}
