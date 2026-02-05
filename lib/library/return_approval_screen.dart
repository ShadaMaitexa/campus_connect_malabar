import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ReturnApproval extends StatefulWidget {
  const ReturnApproval({super.key});

  @override
  State<ReturnApproval> createState() => _ReturnApprovalState();
}

class _ReturnApprovalState extends State<ReturnApproval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text("Return Approvals", style: GoogleFonts.outfit()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .where('returned', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fact_check_rounded, size: 64, color: AppTheme.darkBorder),
                  const SizedBox(height: 16),
                  Text("No pending returns", 
                    style: GoogleFonts.inter(color: AppTheme.darkTextSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['bookTitle'] ?? 'Unknown Book', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text("Issued to: ${data['studentName'] ?? 'Unknown'}",
                    style: const TextStyle(color: AppTheme.darkTextSecondary)),
                  trailing: ElevatedButton(
                    onPressed: () => _approveReturn(docId, data['bookId']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveReturn(String docId, String? bookId) async {
    try {
      await FirebaseFirestore.instance
          .collection('issued_books')
          .doc(docId)
          .update({
        'returned': true,
        'returnedAt': FieldValue.serverTimestamp(),
      });

      if (bookId != null) {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(bookId)
            .update({
          'availableCopies': FieldValue.increment(1),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Return approved successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
