import 'package:campus_connect_malabar/screens/alumini_dashboard.dart';
import 'package:flutter/material.dart';

import 'post_job.dart';
import '../student/view_events.dart';
import '../profile/profile_screen.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  int index = 0;

  final screens = const [
    AlumniHome(),
    PostJob(),
    ViewEvents(),
    AlumniJobsInfo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alumni Dashboard"),
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
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Post Job"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Impact"),
        ],
      ),
    );
  }
}


class AlumniJobsInfo extends StatelessWidget {
  const AlumniJobsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Your posted jobs help students\nbuild their careers",
        textAlign: TextAlign.center,
      ),
    );
  }
}
