import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/cloudinary_service.dart';
import '../services/library_service.dart';
import '../widgets/book_image_picker.dart';
import '../theme/app_theme.dart';

class ManageBooks extends StatefulWidget {
  const ManageBooks({super.key});

  @override
  State<ManageBooks> createState() => _ManageBooksState();
}

class _ManageBooksState extends State<ManageBooks> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _copiesController = TextEditingController();

  Uint8List? _bookImageBytes;
  XFile? _pickedImage;

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = file;
        _bookImageBytes = bytes;
      });
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload book cover image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String imageUrl = await CloudinaryService.uploadBookImage(
        _bookImageBytes!,
        filename: _pickedImage!.name,
      );

      await LibraryService.addBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        imageUrl: imageUrl,
        totalCopies: int.parse(_copiesController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book added successfully")),
        );
      }

      _formKey.currentState!.reset();
      setState(() {
        _bookImageBytes = null;
        _pickedImage = null;
        _titleController.clear();
        _authorController.clear();
        _copiesController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/generated_background.png",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: AppTheme.darkBackground.withOpacity(0.92)),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Library Inventory",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // --- ADD NEW BOOK SECTION ---
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Add New Book",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: BookImagePicker(
                                imageBytes: _bookImageBytes,
                                onPick: _pickImage,
                              ),
                            ),
                            const SizedBox(height: 48),
                            _buildPremiumInput(
                              controller: _titleController,
                              label: "Book Title",
                              icon: Icons.title_rounded,
                            ),
                            const SizedBox(height: 24),
                            _buildPremiumInput(
                              controller: _authorController,
                              label: "Author Name",
                              icon: Icons.person_rounded,
                            ),
                            const SizedBox(height: 24),
                            _buildPremiumInput(
                              controller: _copiesController,
                              label: "Total Copies",
                              icon: Icons.copy_rounded,
                              isNumber: true,
                            ),
                            const SizedBox(height: 40),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _isLoading ? null : _saveBook,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Save to Inventory",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // --- CURRENT INVENTORY SECTION ---
                    Row(
                      children: [
                        Container(width: 4, height: 24, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 12),
                        Text("Current Inventory", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('books').orderBy('createdAt', descending: true).snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                        if (snap.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
                                  const SizedBox(height: 16),
                                  Text("No books found", style: GoogleFonts.inter(color: Colors.white24)),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snap.data!.docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final book = snap.data!.docs[index];
                            final data = book.data() as Map<String, dynamic>;
                            final available = data['availableCopies'] ?? 0;
                            final total = data['totalCopies'] ?? 0;

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      data['imageUrl'] ?? '',
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60, height: 80,
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        child: const Icon(Icons.book_rounded, color: AppTheme.primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? 'Unknown',
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "by ${data['author'] ?? 'Unknown'}",
                                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _badge("${available}/${total} Available", available > 0 ? Colors.green : Colors.red),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: AppTheme.darkSurface,
                                          title: const Text("Remove Book", style: TextStyle(color: Colors.white)),
                                          content: const Text("Delete this book from the library?", style: TextStyle(color: Colors.white70)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('books').doc(book.id).delete();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPremiumInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (v) => v == null || v.isEmpty ? "Required field" : null,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppTheme.primaryColor.withOpacity(0.5),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}
