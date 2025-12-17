import 'package:flutter/material.dart';
import 'manage_books.dart';

class LibraryAdminDashboard extends StatelessWidget {
  const LibraryAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Admin Panel"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.library_books),
          label: const Text("Manage Books"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageBooks()),
            );
          },
        ),
      ),
    );
  }
}
