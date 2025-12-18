import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminNotices extends StatefulWidget {
  const AdminNotices({super.key});

  @override
  State<AdminNotices> createState() => _AdminNoticesState();
}

class _AdminNoticesState extends State<AdminNotices> {
  final TextEditingController title = TextEditingController();
  final TextEditingController message = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    title.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> postNotice() async {
    if (title.text.trim().isEmpty || message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and message cannot be empty")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('notices').add({
      'title': title.text.trim(),
      'message': message.text.trim(),
      'department': 'ALL',
      'role': 'admin',
      'createdAt': Timestamp.now(),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Global notice posted successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar("Post Global Notice"),
      body: _page(
        child: _card(
          children: [
            _input(
              title,
              "Notice Title",
              Icons.title,
            ),
            _input(
              message,
              "Notice Message",
              Icons.message,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : _button("Post Notice", postNotice),
          ],
        ),
      ),
    );
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
      child: Center(
        child: SingleChildScrollView(child: child),
      ),
    );

Widget _card({required List<Widget> children}) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // ✅ premium radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

Widget _input(
  TextEditingController c,
  String label,
  IconData icon, {
  int maxLines = 1,
  TextInputType type = TextInputType.text,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
