import 'package:campus_connect_malabar/alumini/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/profile_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("Job Openings"),
      body: _page(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('marketplace')
              .where('type', isEqualTo: 'job')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return _empty("No job openings available");
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _jobCard(context, snapshot.data!.docs[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _jobCard(BuildContext context, QueryDocumentSnapshot doc) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(doc['postedBy'])
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const SizedBox();

        final user = userSnap.data!;

        return Container(
          decoration: _card(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc['title'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                doc['company'],
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                doc['description'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const Divider(height: 28),

              _userRow(context, user),
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
          radius: 22,
          backgroundColor: const Color(0xFF6366F1),
          backgroundImage:
              user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                  ? NetworkImage(user['photoUrl'])
                  : null,
          child: (user['photoUrl'] == null ||
                  user['photoUrl'].toString().isEmpty)
              ? Text(
                  user['name'][0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                user['role'].toString().toUpperCase(),
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: user.id),
              ),
            );
          },
          child: const Text("View Profile"),
        ),
        IconButton(
          icon: const Icon(Icons.chat, color: Color(0xFF6366F1)),
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
PreferredSizeWidget _appBar(String title) => AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 0,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );

Decoration _card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ],
    );

Widget _empty(String text) => Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
