import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinePaymentsScreen extends StatelessWidget {
  const FinePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Fine Payments", showBackButton: true),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issued_books')
                .where('returned', isEqualTo: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snap.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.receipt_long,
                    title: "No Fine Payments",
                    subtitle: "No books have been returned yet.",
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = snap.data!.docs[index];
                  return AppAnimations.slideInFromBottom(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(doc['bookTitle']),
                      subtitle: Text("Student: ${doc['studentId']}"),
                      trailing: const Text("Paid"),
                    ),
                  );
                }, childCount: snap.data!.docs.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
