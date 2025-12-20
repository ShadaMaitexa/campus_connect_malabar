import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListings extends StatelessWidget {
  const MyListings({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          /// 🔹 TABS
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF6366F1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF6366F1),
              tabs: [
                Tab(text: "Study Materials"),
                Tab(text: "Jobs"),
              ],
            ),
          ),

          /// 🔹 TAB CONTENT
          Expanded(
            child: TabBarView(
              children: [
                _buildList(uid, 'material'),
                _buildList(uid, 'job'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SHARED LIST BUILDER
  Widget _buildList(String uid, String type) {
    return Container(
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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('marketplace')
            .where('sellerId', isEqualTo: uid)
            .where('type', isEqualTo: type)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return Center(
              child: Text(
                type == 'material'
                    ? "No study materials posted yet"
                    : "No jobs posted yet",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snap.data!.docs[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        type == 'material'
                            ? Icons.menu_book
                            : Icons.work,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          /// 🔹 STATUS FOR MATERIAL
                          if (type == 'material')
                            Text(
                              doc['status'] == 'available'
                                  ? 'Available'
                                  : 'Taken',
                              style: TextStyle(
                                color: doc['status'] == 'available'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          /// 🔹 JOB LABEL
                          if (type == 'job')
                            const Text(
                              "Job Post",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),

                    /// ACTIONS
                    Column(
                      children: [
                        /// TOGGLE STATUS (MATERIAL ONLY)
                        if (type == 'material')
                          IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: 'Toggle status',
                            onPressed: () {
                              final newStatus =
                                  doc['status'] == 'available'
                                      ? 'taken'
                                      : 'available';
                              doc.reference
                                  .update({'status': newStatus});
                            },
                          ),

                        /// DELETE
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => doc.reference.delete(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
