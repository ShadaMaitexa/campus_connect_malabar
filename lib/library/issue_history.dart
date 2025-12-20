import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueHistoryScreen extends StatelessWidget {
  const IssueHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Issue History", showBackButton: true),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issued_books')
                .orderBy('issuedAt', descending: true)
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
                    icon: Icons.library_books,
                    title: "No Issue History",
                    subtitle: "No books have been issued yet.",
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = snap.data!.docs[index];
                  return AppAnimations.slideInFromBottom(
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(doc['bookTitle']),
                        subtitle: Text(
                          "Issued: ${doc['issuedAt'].toDate().toString().split(' ')[0]}",
                        ),
                        trailing: Text(
                          doc['returned'] ? "Returned" : "Not Returned",
                        ),
                      ),
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
