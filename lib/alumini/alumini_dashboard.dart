import 'package:flutter/material.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  int index = 0;

  final screens = const [
    AlumniHome(),
    AlumniJobs(),
    AlumniStories(),
    AlumniProfile(),
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
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Stories"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class AlumniHome extends StatelessWidget {
  const AlumniHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alumni Dashboard")),
      body: const Center(child: Text("Alumni Engagement Overview")),
    );
  }
}

class AlumniJobs extends StatelessWidget {
  const AlumniJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Jobs")),
      body: const Center(child: Text("Add Job Opportunities")),
    );
  }
}

class AlumniStories extends StatelessWidget {
  const AlumniStories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Success Stories")),
      body: const Center(child: Text("Share Career Journey")),
    );
  }
}

class AlumniProfile extends StatelessWidget {
  const AlumniProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("Alumni Details • Logout")),
    );
  }
}
