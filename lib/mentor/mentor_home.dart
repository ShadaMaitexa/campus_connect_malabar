import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorHome extends StatelessWidget {
  const MentorHome({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold( appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Mentor Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenu(),
          ),
        ],
      ),
    
    body: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dept = snap.data!['department'];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  children: [
                    _studentsCount(dept),
                    _attendanceStatus(),
                    _noticeCount(uid),
                    _eventCount(uid),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  // ---------------- STUDENTS ----------------
  Widget _studentsCount(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _dashboardCard(
          title: "Students",
          value: "$count",
          icon: Icons.group,
          gradient: _blueGradient,
        );
      },
    );
  }

  // ---------------- ATTENDANCE ----------------
  Widget _attendanceStatus() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        final marked = snap.hasData && snap.data!.exists;
        return _dashboardCard(
          title: "Attendance",
          value: marked ? "Marked" : "Pending",
          icon: Icons.check_circle,
          gradient: marked ? _greenGradient : _orangeGradient,
        );
      },
    );
  }

  // ---------------- NOTICES ----------------
  Widget _noticeCount(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _dashboardCard(
          title: "Notices",
          value: "$count",
          icon: Icons.campaign,
          gradient: _purpleGradient,
        );
      },
    );
  }

  // ---------------- EVENTS ----------------
  Widget _eventCount(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        return _dashboardCard(
          title: "Events",
          value: "$count",
          icon: Icons.event,
          gradient: _blueGradient,
        );
      },
    );
  }

  // ---------------- CARD UI ----------------
  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- GRADIENTS ----------------
  static const _blueGradient = LinearGradient(
    colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
  );

  static const _greenGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
  );

  static const _purpleGradient = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  );
}
