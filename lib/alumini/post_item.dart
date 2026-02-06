import 'dart:io';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
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

  File? image;
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> postMaterial() async {
    if (loading) return;

    if (title.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      // 🔹 Upload image
      final imageUrl = await CloudinaryService.upload(image!);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("Image upload failed");
      }

      // 🔹 Save to Firestore
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
        const SnackBar(content: Text("Material posted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post material")));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Post Study Material", showBackButton: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppAnimations.slideInFromBottom(
              child: _page(
                child: _card(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                          image: image != null
                              ? DecorationImage(
                                  image: FileImage(image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: image == null
                            ? const Center(child: Icon(Icons.upload, size: 42))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _input(title, "Material Title", Icons.menu_book),
                    _input(
                      description,
                      "Description",
                      Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    loading
                        ? const CircularProgressIndicator()
                        : _button("Post Material", postMaterial),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- UI HELPERS (UNCHANGED) ----------------

PreferredSizeWidget _appBar(String title) => AppBar(
  elevation: 0,
  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    ),
  ),
);

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
