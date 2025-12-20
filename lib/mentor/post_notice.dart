import 'package:campus_connect_malabar/widgets/app_text_field.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_app_bar.dart';

import '../theme/app_theme.dart';
import '../utils/animations.dart';


class PostNotice extends StatefulWidget {
  const PostNotice({super.key});

  @override
  State<PostNotice> createState() => _PostNoticeState();
}

class _PostNoticeState extends State<PostNotice> {
  final title = TextEditingController();
  final message = TextEditingController();

  bool loading = false;

  Future<void> postNotice() async {
    if (title.text.isEmpty || message.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    await FirebaseFirestore.instance.collection('notices').add({
      'title': title.text.trim(),
      'message': message.text.trim(),
      'department': userDoc['department'],
      'postedBy': userDoc['name'],
      'role': 'mentor',
      'createdAt': Timestamp.now(),
    });

    title.clear();
    message.clear();

    setState(() => loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notice posted successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: CustomAppBar(
        title: "Post Notice",
        gradient: AppGradients.blue,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // INFO CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create a Notice",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "This notice will be visible to students of your department.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // TITLE FIELD
                  AppAnimations.slideInFromBottom(
                    delay: const Duration(milliseconds: 200),
                    child: AppTextField(
                      controller: title,
                      label: "Notice Title",
                      prefixIcon: Icons.title,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // MESSAGE FIELD
                  AppAnimations.slideInFromBottom(
                    delay: const Duration(milliseconds: 400),
                    child: AppTextField(
                      controller: message,
                      label: "Notice Message",
                      prefixIcon: Icons.message,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // POST BUTTON
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: postNotice,
                    icon: const Icon(Icons.send),
                    label: const Text("Post Notice"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ))]));
  }
}
