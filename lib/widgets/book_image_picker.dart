import 'dart:typed_data';
import 'package:flutter/material.dart';

class BookImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPick;

  const BookImagePicker({
    super.key,
    required this.imageBytes,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueGrey.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.blueGrey.shade300,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: imageBytes == null
            ? _placeholder()
            : _imagePreview(),
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueGrey.shade100,
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            size: 42,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload Book Cover",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Click to choose from gallery",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }
}
