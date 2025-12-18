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
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'department': department,
        'approved': role == 'student',
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<List<String>> getDepartments() async {
    try {
      final snapshot = await _db.collection('departments').get();
      return snapshot.docs.map((d) => d['name'] as String).toList();
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('User document not found');
      }
      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> saveUser({
    required String uid,
    required String name,
    required String role,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'role': role,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('User document not found');
      }
      return doc['role'] as String? ?? 'student';
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }
}
