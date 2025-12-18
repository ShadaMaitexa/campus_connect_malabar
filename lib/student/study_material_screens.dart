import 'package:campus_connect_malabar/alumini/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/profile_screen.dart';


class StudyMaterialsScreen extends StatelessWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('marketplace')
          .where('type', isEqualTo: 'material')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            final item = snap.data!.docs[index];

            return _materialCard(context, item);
          },
        );
      },
    );
  }

  Widget _materialCard(BuildContext context, QueryDocumentSnapshot doc) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(doc['postedBy'])
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const SizedBox();

        final user = userSnap.data!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: Image.network(
                  doc['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("₹${doc['price']}"),

                    const Divider(height: 24),

                    _userRow(context, user),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userRow(BuildContext context, DocumentSnapshot user) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF6366F1),
          child: Text(user['name'][0]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            user['name'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          child: const Text("View Profile"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: user.id),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  userId: user.id,
                  name: user['name'],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
