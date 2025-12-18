import 'package:campus_connect_malabar/library/fine_payment_screen.dart';
import 'package:campus_connect_malabar/library/issue_history.dart';
import 'package:campus_connect_malabar/library/issued_book_screen.dart';
import 'package:flutter/material.dart';
import 'manage_books.dart';

import 'library_analytics_screen.dart';

class LibraryAdminDashboard extends StatelessWidget {
  const LibraryAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Library Admin Panel",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 1.2,
          ),
          children: [
            _card(context, "Manage Books", Icons.library_add,
                const ManageBooks()),

            _card(context, "Return Approvals", Icons.assignment_turned_in,
                const IssuedBooksScreen()),

            _card(context, "Fine Payments", Icons.payments,
                const FinePaymentsScreen()),

            _card(context, "Library Analytics", Icons.bar_chart,
                const LibraryAnalyticsScreen()),

            _card(context, "Issue History", Icons.history,
                const IssueHistoryScreen()),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 14),
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
  }
}
