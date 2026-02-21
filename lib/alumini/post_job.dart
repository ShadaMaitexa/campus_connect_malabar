import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> postJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection('marketplace').add({
        'type': 'job',
        'title': title.text.trim(),
        'company': company.text.trim(),
        'description': description.text.trim(),
        'applyLink': link.text.trim(),
        'postedBy': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Job posted successfully"),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to post job"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          const isDark = true;
          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            appBar: CustomAppBar(
              title: "Post Job Opening",
              showBackButton: true,
              gradient: AppGradients.info,
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
                child: AppAnimations.slideInFromBottom(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Job Information", isDark),
                        const SizedBox(height: 16),
                        _card(
                          isDark: isDark,
                          children: [
                            _input(
                              title,
                              "Job Title",
                              Icons.work_outline,
                              isDark,
                              validator: (v) =>
                                  v!.isEmpty ? "Title is required" : null,
                            ),
                            _input(
                              company,
                              "Company Name",
                              Icons.business,
                              isDark,
                              validator: (v) => v!.isEmpty
                                  ? "Company name is required"
                                  : null,
                            ),
                            _input(
                              description,
                              "Job Description",
                              Icons.description,
                              isDark,
                              maxLines: 4,
                              validator: (v) =>
                                  v!.isEmpty ? "Description is required" : null,
                            ),
                            _input(
                              link,
                              "Apply Link / Contact",
                              Icons.link,
                              isDark,
                              hint: "Enter URL, Email or Phone Number",
                              validator: (v) => v!.isEmpty
                                  ? "Contact info is required"
                                  : null,
                            ),
                            const SizedBox(height: 32),
                            loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _button("Post Job", postJob),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
      ),
    );
  }

  Widget _card({required List<Widget> children, required bool isDark}) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              Text(
                " *",
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: c,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint ?? "Enter $label",
              prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
              filled: true,
              fillColor: isDark
                  ? AppTheme.darkSurfaceSecondary
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
