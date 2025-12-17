import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostItem extends StatefulWidget {
  const PostItem({super.key});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final title = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();

  String category = 'Book';
  bool loading = false;

  Future<void> postItem() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await FirebaseFirestore.instance.collection('marketplace').add({
      'title': title.text.trim(),
      'description': description.text.trim(),
      'price': price.text.trim(),
      'category': category,
      'sellerId': uid,
      'sellerName': userDoc['name'],
      'sellerRole': userDoc['role'],
      'contactEmail': userDoc['email'],
      'available': true,
      'createdAt': Timestamp.now(),
    });

    title.clear();
    description.clear();
    price.clear();

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item posted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Item Title"),
            ),
            TextField(
              controller: description,
              decoration:
                  const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            TextField(
              controller: price,
              decoration: const InputDecoration(labelText: "Price (₹)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration:
                  const InputDecoration(labelText: "Category"),
              items: const [
                DropdownMenuItem(value: "Book", child: Text("Book")),
                DropdownMenuItem(value: "Notes", child: Text("Notes")),
                DropdownMenuItem(
                    value: "Electronics",
                    child: Text("Electronics")),
              ],
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: postItem,
                    child: const Text("Post Item"),
                  ),
          ],
        ),
      ),
    );
  }
}
