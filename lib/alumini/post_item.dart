import 'dart:io';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloudinary_service.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? image;
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> postMaterial() async {
    if (loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please upload an image of the material"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final imageUrl = await CloudinaryService.upload(image!);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("Image upload failed");
      }

      await FirebaseFirestore.instance.collection('marketplace').add({
        'type': 'material',
        'title': title.text.trim(),
        'description': description.text.trim(),
        'imageUrl': imageUrl,
        'postedBy': FirebaseAuth.instance.currentUser!.uid,
        'status': 'available',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Material posted successfully"),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to post material"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: CustomAppBar(
        title: "Post Study Material",
        showBackButton: true,
        gradient: AppGradients.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.darkBackground,
                  ]
                : [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.lightBackground,
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
                  _buildSectionTitle("Material Details", isDark),
                  const SizedBox(height: 16),
                  _card(
                    isDark: isDark,
                    children: [
                      _buildImageUpload(isDark),
                      const SizedBox(height: 24),
                      _input(
                        title,
                        "Material Title",
                        Icons.menu_book,
                        isDark,
                        validator: (v) =>
                            v!.isEmpty ? "Title is required" : null,
                      ),
                      _input(
                        description,
                        "Description",
                        Icons.description,
                        isDark,
                        maxLines: 4,
                        validator: (v) =>
                            v!.isEmpty ? "Description is required" : null,
                      ),
                      const SizedBox(height: 32),
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : _button("Post Material", postMaterial),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildImageUpload(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Upload Photo",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            Text(" *", style: TextStyle(color: AppTheme.errorColor)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Supported: JPG, PNG • Max 5MB",
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? AppTheme.darkSurfaceSecondary
                  : Colors.grey.shade100,
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 2,
                style: BorderStyle.solid,
              ),
              image: image != null
                  ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
                  : null,
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Click to select image",
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
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
              Text(" *", style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: "Enter $label",
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
