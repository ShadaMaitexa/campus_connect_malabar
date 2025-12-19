import 'package:campus_connect_malabar/admin/admin_users.dart';
import 'package:campus_connect_malabar/admin/post_event.dart';
import 'package:campus_connect_malabar/admin/post_global_notice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'admin_jobs.dart';
import 'approve_users.dart';
import 'admin_library.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, "Admin Control Panel"),
      body: _page(
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
          children: [
            _card(context, "Jobs & Materials", Icons.work, const AdminJobs()),
            _card(context, "Events", Icons.event, const AdminViewEvents()),
            _card(context, "Global Notices", Icons.campaign,
                const AdminNotices()),
            _card(context, "Approve Mentors", Icons.verified_user,
                const ApproveUsers()),
            _card(context, "Users (Block Alumni)", Icons.block,
                const AdminUsers()),
            _card(context, "Library", Icons.library_books,
                const AdminLibrary()),
          ],
        ),
      ),
    );
  }
}

// -------------------- APP BAR WITH LOGOUT --------------------
PreferredSizeWidget _appBar(BuildContext context, String title) => AppBar(
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          tooltip: "Logout",
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
      ),
    );

// -------------------- PAGE BACKGROUND --------------------
Widget _page({required Widget child}) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.06),
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );

// -------------------- DASHBOARD CARD --------------------
Widget _card(
  BuildContext context,
  String title,
  IconData icon,
  Widget page,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.22),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
