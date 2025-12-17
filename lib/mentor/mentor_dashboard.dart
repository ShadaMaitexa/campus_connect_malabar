import 'package:campus_connect_malabar/mentor/mentor_home.dart';
import 'package:flutter/material.dart';

import 'attendance_screen.dart';
import 'post_notice.dart';
import 'post_event.dart';
import '../profile/profile_screen.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int index = 0;

  final screens = const [
    MentorHome(),
    AttendanceScreen(),
    PostNotice(),
    MentorPostEvent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentor Dashboard"),
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
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Notices"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        ],
      ),
    );
  }
}