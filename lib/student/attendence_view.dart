import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "My Attendance",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('attendance')
            .doc(today())
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists ||
              !(snapshot.data!.data() as Map<String, dynamic>)
                  .containsKey(uid)) {
            return _emptyState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final present = data[uid]['present'];

          return Center(
            child: _attendanceStatusCard(present),
          );
        },
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Attendance not marked today",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- STATUS CARD ----------------
  Widget _attendanceStatusCard(bool present) {
    final gradient = present ? _greenGradient : _redGradient;
    final icon = present ? Icons.check_circle : Icons.cancel;
    final text = present ? "PRESENT" : "ABSENT";
    final subtitle =
        present ? "You were marked present today" : "You were marked absent";

    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------- GRADIENTS ----------------
  static const _greenGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const _redGradient = LinearGradient(
    colors: [Color(0xFFCB2D3E), Color(0xFFEF473A)],
  );
}
