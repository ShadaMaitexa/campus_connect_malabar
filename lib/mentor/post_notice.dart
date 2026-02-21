import 'package:campus_connect_malabar/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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

    try {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notice published successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: "Post Notice",
          subtitle: "Communicate with students",
          gradient: AppGradients.accent,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.05),
                AppTheme.darkBackground,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppAnimations.slideInFromBottom(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Create a Notice",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "This notice will be instantly visible to students in your department.",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: title,
                          label: "Notice Title",
                          prefixIcon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: message,
                          label: "Notice Message",
                          prefixIcon: Icons.message_rounded,
                          maxLines: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppAnimations.slideInFromBottom(
                  delay: const Duration(milliseconds: 200),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: postNotice,
                            icon: const Icon(Icons.send_rounded),
                            label: Text(
                              "Publish Notice",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
