import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBooks extends StatefulWidget {
  const ManageBooks({super.key});

  @override
  State<ManageBooks> createState() => _ManageBooksState();
}

class _ManageBooksState extends State<ManageBooks> {
  final title = TextEditingController();
  final author = TextEditingController();
  final category = TextEditingController();

  Future<void> addBook() async {
    if (title.text.isEmpty || author.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('books').add({
      'title': title.text.trim(),
      'author': author.text.trim(),
      'category': category.text.trim(),
      'available': true,
      'addedAt': Timestamp.now(),
    });

    title.clear();
    author.clear();
    category.clear();
  }

  Future<void> toggleAvailability(String docId, bool current) async {
    await FirebaseFirestore.instance
        .collection('books')
        .doc(docId)
        .update({'available': !current});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Books")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Book Title"),
                ),
                TextField(
                  controller: author,
                  decoration: const InputDecoration(labelText: "Author"),
                ),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addBook,
                  child: const Text("Add Book"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('addedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text("${data['author']} • ${data['category']}"),
                      trailing: Switch(
                        value: data['available'],
                        activeColor: Colors.green,
                        onChanged: (_) =>
                            toggleAvailability(doc.id, data['available']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
