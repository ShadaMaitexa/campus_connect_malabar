import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLibrary extends StatelessWidget {
  const AdminLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("Library Overview"),
      body: _page(
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            return ListView(
              children: snapshot.data!.docs.map((book) {
                return _adminCard(
                  title: book['title'],
                  subtitle:
                      "Available: ${book['availableCopies']}",
                  onDelete: () => book.reference.delete(),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
PreferredSizeWidget _appBar(String title) => AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
      ),
    );

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
      child: child,
    );

Widget _adminCard({
  required String title,
  required String subtitle,
  required VoidCallback onDelete,
}) =>
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
