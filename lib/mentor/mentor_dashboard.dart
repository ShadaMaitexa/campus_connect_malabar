import 'package:campus_connect_malabar/mentor/attendance_screen.dart';
import 'package:flutter/material.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int index = 0;

  final screens = const [
    MentorHome(),
    MentorAttendance(),
    MentorNotices(),
    MentorProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Notices"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class MentorHome extends StatelessWidget {
  const MentorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentor Dashboard")),
      body: const Center(child: Text("Assigned Students Overview")),
    );
  }
}


class MentorNotices extends StatelessWidget {
  const MentorNotices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Notices")),
      body: const Center(child: Text("Create & Manage Notices")),
    );
  }
}

class MentorProfile extends StatelessWidget {
  const MentorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("Mentor Details • Logout")),
    );
  }
}
