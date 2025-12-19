import 'package:campus_connect_malabar/library/library_screen.dart';
import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  String today() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Dashboard",
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenu(),
          ),
        ],
      ),
    body: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final department = userSnap.data!['department'];

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
                    _attendanceCard(uid),
                    _todayStatusCard(uid),
                    _noticeCountCard(department),
                    _eventCountCard(department),
                    _libraryCard(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  // -------------------- ATTENDANCE --------------------
  Widget _attendanceCard(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _dashboardCard(
            title: "Attendance",
            value: "--",
            icon: Icons.bar_chart,
            gradient: _blueGradient,
          );
        }

        int total = 0;
        int present = 0;

        for (var doc in snap.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey(uid)) {
            total++;
            if (data[uid]['present'] == true) present++;
          }
        }

        final percent = total == 0 ? 0 : ((present / total) * 100).round();

        return _dashboardCard(
          title: "Attendance",
          value: "$percent%",
          icon: Icons.bar_chart,
          gradient: percent >= 75 ? _greenGradient : _orangeGradient,
        );
      },
    );
  }

  // -------------------- TODAY STATUS --------------------
  Widget _todayStatusCard(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .doc(today())
          .get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return _dashboardCard(
            title: "Today",
            value: "Not Marked",
            icon: Icons.help_outline,
            gradient: _greyGradient,
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        if (!data.containsKey(uid)) {
          return _dashboardCard(
            title: "Today",
            value: "Not Marked",
            icon: Icons.help_outline,
            gradient: _greyGradient,
          );
        }

        final present = data[uid]['present'];

        return _dashboardCard(
          title: "Today",
          value: present ? "Present" : "Absent",
          icon: present ? Icons.check_circle : Icons.cancel,
          gradient: present ? _greenGradient : _redGradient,
        );
      },
    );
  }

  // -------------------- NOTICES --------------------
  Widget _noticeCountCard(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('department', isEqualTo: dept)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;

        return _dashboardCard(
          title: "Notices",
          value: "$count",
          icon: Icons.notifications,
          gradient: _purpleGradient,
        );
      },
    );
  }

  // -------------------- EVENTS --------------------
  Widget _eventCountCard(String dept) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _dashboardCard(
            title: "Events",
            value: "0",
            icon: Icons.event,
            gradient: _blueGradient,
          );
        }

        final count = snap.data!.docs.where((d) {
          return d['department'] == 'ALL' || d['department'] == dept;
        }).length;

        return _dashboardCard(
          title: "Events",
          value: "$count",
          icon: Icons.event,
          gradient: _blueGradient,
        );
      },
    );
  }
Widget _libraryCard(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LibraryScreen(),
        ),
      );
    },
    child: _dashboardCard(
      title: "Library",
      value: "Books",
      icon: Icons.library_books,
      gradient: const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43)],
      ),
    ),
  );
}

  // -------------------- CARD UI --------------------
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

  // -------------------- GRADIENTS --------------------
  static const _blueGradient = LinearGradient(
    colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
  );

  static const _greenGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
  );

  static const _redGradient = LinearGradient(
    colors: [Color(0xFFCB2D3E), Color(0xFFEF473A)],
  );

  static const _purpleGradient = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  );

  static const _greyGradient = LinearGradient(
    colors: [Color(0xFF757F9A), Color(0xFF283048)],
  );
}
