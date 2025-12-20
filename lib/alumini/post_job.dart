import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/animations.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final title = TextEditingController();
  final company = TextEditingController();
  final description = TextEditingController();
  final link = TextEditingController();

  bool loading = false;

  Future<void> postJob() async {
    if (title.text.isEmpty ||
        company.text.isEmpty ||
        description.text.isEmpty ||
        link.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('marketplace').add({
      'type': 'job',
      'title': title.text.trim(),
      'company': company.text.trim(),
      'description': description.text.trim(),
      'applyLink': link.text.trim(),
      'postedBy': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': Timestamp.now(),
    });

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar(title: "Post Job Opening", showBackButton: true),
      body: _page(
        child: _card(
          children: [
            _input(title, "Job Title", Icons.work_outline),
            _input(company, "Company Name", Icons.business),
            _input(
              description,
              "Job Description",
              Icons.description,
              maxLines: 3,
            ),
            _input(link, "Apply Link / Contact", Icons.link),
            const SizedBox(height: 24),
            loading
                ? const CircularProgressIndicator()
                : _button("Post Job", postJob),
          ],
        ),
      ),
    );
  }
}

Widget _page({required Widget child}) => Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF6366F1).withOpacity(0.06), Colors.white],
    ),
  ),
  child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child),
);

Widget _card({required List<Widget> children}) => Container(
  padding: const EdgeInsets.all(26),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Column(children: children),
);

Widget _input(
  TextEditingController c,
  String label,
  IconData icon, {
  int maxLines = 1,
  TextInputType type = TextInputType.text,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: TextField(
    controller: c,
    maxLines: maxLines,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);

Widget _button(String label, VoidCallback onTap) => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  ),
);
