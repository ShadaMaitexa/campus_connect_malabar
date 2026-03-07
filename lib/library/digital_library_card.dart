import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';

class DigitalLibraryCard extends StatefulWidget {
  final String registerNumber;
  final String studentName;
  final String department;
  final String? photoUrl;
  final String uid;

  const DigitalLibraryCard({
    super.key,
    required this.registerNumber,
    required this.studentName,
    required this.department,
    this.photoUrl,
    required this.uid,
  });

  @override
  State<DigitalLibraryCard> createState() => _DigitalLibraryCardState();
}

class _DigitalLibraryCardState extends State<DigitalLibraryCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/library_card.png').create();
        await imagePath.writeAsBytes(image);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'My Digital Library Card - ${widget.studentName}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Digital Library Card",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isSharing)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: _shareCard,
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Screenshot(
                controller: _screenshotController,
                child: _buildCard(),
              ),
              const SizedBox(height: 48),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 340,
      height: 540,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Design
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.05),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // College Header
                Row(
                  children: [
                    Image.asset(
                      'assets/icon/logo.png',
                      height: 40,
                      errorBuilder: (_,__,___) => const Icon(Icons.school, color: AppTheme.primaryColor, size: 40),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CAMPUS CONNECT",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "MALABAR COLLEGE",
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Student Photo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                    image: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(widget.photoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: widget.photoUrl == null || widget.photoUrl!.isEmpty
                      ? const Center(child: Icon(Icons.person, color: Colors.white24, size: 60))
                      : null,
                ),
                
                const SizedBox(height: 20),
                
                // Student Name
                Text(
                  widget.studentName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.department,
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Details Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      _detailItem("REG NO", widget.registerNumber),
                      Container(width: 1, height: 30, color: Colors.white10),
                      _detailItem("TYPE", "STUDENT"),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // QR Code
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: widget.uid,
                      version: QrVersions.auto,
                      size: 140.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  "LIBRARY ACCESS CODE",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "N/A" : value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Instructions",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _instructionStep(Icons.qr_code_scanner_rounded, "Present this QR code at the library desk for scanning."),
          _instructionStep(Icons.download_for_offline_rounded, "Download or take a screenshot for offline use."),
          _instructionStep(Icons.security_rounded, "This card is uniquely linked to your student ID."),
        ],
      ),
    );
  }

  Widget _instructionStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
