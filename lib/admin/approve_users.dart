import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveUsers extends StatelessWidget {
  const ApproveUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approve Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No pending approvals"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index];

              return Card(
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Text("${user['role']} • ${user['email']}"),
                  trailing: ElevatedButton(
                    child: const Text("Approve"),
                    onPressed: () async {
                      await user.reference.update({'approved': true});

                      // 🔔 EmailJS hook (already discussed)
                      // EmailService.sendApprovalMail(user['email'], user['name']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("User approved successfully")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
