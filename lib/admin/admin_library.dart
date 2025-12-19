import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLibrary extends StatelessWidget {
  const AdminLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("Library Overview"),
      body: _page(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No books available"));
            }

            return ListView(
              children: snapshot.data!.docs.map((book) {
                final data = book.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () => _showBookDetails(context, data),
                  child: _adminCard(
                    title: data['title'],
                    subtitle:
                        "Available: ${data['availableCopies']}",
                    onDelete: () => book.reference.delete(),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- BOTTOM SHEET --------------------
void _showBookDetails(BuildContext context, Map<String, dynamic> book) {
  final issued = book['issuedTo'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // -------- BOOK IMAGE --------
              if (book['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    book['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),

              Text(
                book['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "Available Copies: ${book['availableCopies']}",
                style: const TextStyle(color: Colors.grey),
              ),

              const Divider(height: 32),

              // -------- ISSUE DETAILS --------
              Text(
                "Issue Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: issued != null ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              if (issued == null)
                const Text(
                  "This book is not currently issued",
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow("Issued To", issued['name']),
                    _detailRow("User ID", issued['userId']),
                    _detailRow("Issued Date", issued['issuedDate']),
                    _detailRow("Return Date", issued['returnDate']),
                  ],
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    },
  );
}

// -------------------- HELPERS --------------------
Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(value),
        ),
      ],
    ),
  );
}

// -------------------- APP BAR --------------------
PreferredSizeWidget _appBar(String title) => AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
      ),
    );

// -------------------- PAGE --------------------
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

// -------------------- CARD --------------------
Widget _adminCard({
  required String title,
  required String subtitle,
  required VoidCallback onDelete,
}) =>
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
