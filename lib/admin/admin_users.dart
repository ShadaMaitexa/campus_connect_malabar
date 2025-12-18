import 'package:campus_connect_malabar/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminUsers extends StatelessWidget {
  const AdminUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("Manage Alumni"),
      body: _page(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'alumni')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return _empty("No alumni found");
            }

            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = snapshot.data!.docs[index];
                return _userCard(context, user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _userCard(
      BuildContext context, QueryDocumentSnapshot user) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF6366F1),
            child: Text(
              user['name'][0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'],
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            tooltip: "Block & Remove",
            onPressed: () async {
              final confirm = await _confirmBlock(context);
              if (confirm) {
                await AdminService.blockAlumni(user.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Alumni blocked and data removed"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmBlock(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Block Alumni"),
            content: const Text(
              "This will remove the alumni and all related data. Continue?",
            ),
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
                child: const Text("Block"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/* ================= PREMIUM SHARED UI ================= */

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

Decoration _cardDecoration() => BoxDecoration(
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
