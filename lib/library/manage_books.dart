import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';
import '../services/library_service.dart';
import '../widgets/book_image_picker.dart';

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

  // ================= IMAGE PICK =================
  Future<void> _pickImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = file;
        _bookImageBytes = bytes;
      });
    }
  }

  // ================= SAVE BOOK =================
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
      /// 1️⃣ Upload image to Cloudinary (FIXED)
      final String imageUrl =
          await CloudinaryService.uploadBookImage(
        File(_pickedImage!.path),
      );

      /// 2️⃣ Save book data to Firestore
      await LibraryService.addBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        imageUrl: imageUrl,
        totalCopies: int.parse(_copiesController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Book added successfully")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _bookImageBytes = null;
        _pickedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Books"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookImagePicker(
                imageBytes: _bookImageBytes,
                onPick: _pickImage,
              ),

              const SizedBox(height: 24),

              _inputField(
                controller: _titleController,
                label: "Book Title",
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: _authorController,
                label: "Author",
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: _copiesController,
                label: "Total Copies",
                isNumber: true,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Book"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE FIELD =================
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v == null || v.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
