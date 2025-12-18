import 'package:campus_connect_malabar/student/job_screen.dart';
import 'package:campus_connect_malabar/student/study_material_screens.dart';
import 'package:flutter/material.dart';


class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Marketplace"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Study Materials"),
              Tab(text: "Job Openings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StudyMaterialsScreen(),
            JobsScreen(),
          ],
        ),
      ),
    );
  }
}
