import 'package:campus_connect_malabar/student/attendence_view.dart';
import 'package:campus_connect_malabar/student/stdent_home.dart';
import 'package:flutter/material.dart';


import 'view_notices.dart';
import 'view_events.dart';

import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int index = 0;

  final screens = const [
    StudentHome(),
    StudentAttendanceView(),
    ViewNotices(),
    ViewEvents(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notices"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        ],
      ),
    );
  }
}
