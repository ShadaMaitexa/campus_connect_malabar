import 'package:campus_connect_malabar/auth/login_screen.dart';
import 'package:campus_connect_malabar/library/fine_payment_screen.dart';
import 'package:campus_connect_malabar/library/issue_history.dart';
import 'package:campus_connect_malabar/library/issued_book_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'manage_books.dart';

import 'library_analytics_screen.dart';


class LibraryAdminDashboard extends StatelessWidget {
  const LibraryAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "Library Admin",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: "Logout",
      onPressed: () => _confirmLogout(context),
    ),
  ],
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
    ),
  ),
),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.15,
            children: [
              _card(context, "Manage Books", Icons.library_add, const ManageBooks()),
              _card(context, "Return Approval", Icons.assignment_turned_in, const IssuedBooksScreen()),
              _card(context, "Fine Payments", Icons.payments_rounded, const FinePaymentsScreen()),
              _card(context, "Analytics", Icons.bar_chart_rounded, const LibraryAnalyticsScreen()),
              _card(context, "Issue History", Icons.history_rounded, const IssueHistoryScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 12),
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
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          onPressed: () async {
            Navigator.pop(context);

            await FirebaseAuth.instance.signOut();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );
}

}
