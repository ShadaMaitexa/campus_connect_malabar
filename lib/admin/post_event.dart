import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminViewEvents extends StatelessWidget {
  const AdminViewEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("All Events"),
      body: _page(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return _empty("No events available");
            }

            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final event = snapshot.data!.docs[index];
                return _eventCard(context, event);
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------- EVENT CARD ----------------
  Widget _eventCard(BuildContext context, QueryDocumentSnapshot event) {
    final Timestamp dateTs = event['date'];
    final DateTime eventDate = dateTs.toDate();

    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            event['title'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // DEPARTMENT
          Text(
            "Department: ${event['department']}",
            style: const TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // DESCRIPTION
          Text(
            event['description'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // DATE
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "${eventDate.day}-${eventDate.month}-${eventDate.year}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const Divider(height: 30),

          // ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Remove",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  final confirm = await _confirmDelete(context);
                  if (confirm) {
                    await event.reference.delete();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- CONFIRM DELETE ----------------
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Delete Event"),
            content:
                const Text("Are you sure you want to remove this event?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/* ================= SHARED UI (MATCHES PROFILE & ADMIN) ================= */

PreferredSizeWidget _appBar(String title) => AppBar(
      elevation: 0,
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

Widget _empty(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
