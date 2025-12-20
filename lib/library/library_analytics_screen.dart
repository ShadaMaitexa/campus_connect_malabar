import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/animations.dart';

class LibraryAnalyticsScreen extends StatelessWidget {
  const LibraryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Analytics")),
      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection('books').get(),
          FirebaseFirestore.instance.collection('issued_books').get(),
        ]),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final books = (snap.data![0] as QuerySnapshot).docs.length;
          final issued = (snap.data![1] as QuerySnapshot).docs.length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _card("Total Books", books.toString()),
                _card("Issued Books", issued.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
