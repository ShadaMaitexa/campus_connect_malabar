import 'package:campus_connect_malabar/mentor/mentor_home.dart';
import 'package:campus_connect_malabar/widgets/profile_menu.dart';
import 'package:flutter/material.dart';

import 'attendance_screen.dart';
import 'post_notice.dart';
import 'post_event.dart';

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
     
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: "Notices",
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: "Events",
          ),
        ],
      ),
    );
  }
}
