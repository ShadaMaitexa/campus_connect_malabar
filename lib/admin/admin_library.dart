import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLibrary extends StatelessWidget {
  const AdminLibrary({super.key});

  /// 🔹 Fetch student name from users collection
  Future<String> _getStudentName(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();

    if (!doc.exists) return "Unknown Student";

    final data = doc.data();
    return data?['name'] ?? "Unknown Student";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Overview")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issued_books')
            .orderBy('issuedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 🔹 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔹 Error
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          // 🔹 Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No issued books"));
          }

          final issues = snapshot.data!.docs;

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue =
                  issues[index].data() as Map<String, dynamic>;

              final String studentId = issue['studentId'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(issue['bookTitle'] ?? 'Unknown Book'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 STUDENT NAME FETCHED HERE
                      FutureBuilder<String>(
                        future: _getStudentName(studentId),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text("Issued to: Loading...");
                          }
                          return Text("Issued to: ${snap.data}");
                        },
                      ),
                      Text(
                        "Issued on: ${issue['issuedAt'].toDate()}",
                      ),
                      Text(
                        "Return date: ${issue['returnDate'].toDate()}",
                      ),
                      Text(
                        issue['returned'] == true
                            ? "Status: Returned"
                            : "Status: Not Returned",
                        style: TextStyle(
                          color: issue['returned'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
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
