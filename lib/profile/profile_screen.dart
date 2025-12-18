import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/cloudinary_service.dart';
import '../routing/role_router.dart';
import 'mentor_education_form.dart';
import 'change_password.dart';

class ProfileScreen extends StatefulWidget {
  final bool isFirstTime;
  const ProfileScreen({super.key, this.isFirstTime = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Controllers
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final department = TextEditingController();

  final gender = TextEditingController();
  final dob = TextEditingController();
  final semester = TextEditingController();
  final duration = TextEditingController();

  final designation = TextEditingController();
  final deptStudied = TextEditingController();
  final workingAddress = TextEditingController();
  final passoutYear = TextEditingController();

  final semInCharge = TextEditingController();
  final qualification = TextEditingController();
  final experience = TextEditingController();

  String role = '';
  String? photoUrl;
  String? proofUrl;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      role = data['role'] ?? '';
      name.text = data['name'] ?? '';
      department.text = data['department'] ?? '';
      phone.text = data['personalDetails']?['phone'] ?? '';
      address.text = data['personalDetails']?['address'] ?? '';
      photoUrl = data['photoUrl'];
    });
  }

  Future<void> pickUpload({bool isProof = false}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final url = await CloudinaryService.upload(File(file.path));

    setState(() {
      if (isProof) {
        proofUrl = url;
      } else {
        photoUrl = url;
      }
    });
  }

  Future<void> saveProfile() async {
    final payload = {
      'name': name.text.trim(),
      'department': department.text.trim(),
      'photoUrl': photoUrl,
      'profileCompleted': true,
      'personalDetails': {
        'phone': phone.text.trim(),
        'address': address.text.trim(),
        'gender': gender.text.trim(),
        'dob': dob.text.trim(),
      },
    };

    if (role == 'student') {
      payload['studentDetails'] = {
        'semester': semester.text.trim(),
        'duration': duration.text.trim(),
      };
    }

    if (role == 'alumni') {
      payload['alumniDetails'] = {
        'designation': designation.text.trim(),
        'departmentStudied': deptStudied.text.trim(),
        'workingAddress': workingAddress.text.trim(),
        'passoutYear': passoutYear.text.trim(),
        'proofUrl': proofUrl,
        'verified': false,
      };
    }

    if (role == 'mentor') {
      payload['mentorDetails'] = {
        'semesterInCharge': semInCharge.text.trim(),
        'qualification': qualification.text.trim(),
        'experienceYears': experience.text.trim(),
      };
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(payload);

    if (widget.isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleRouter(role: role)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.isFirstTime ? "Complete Profile" : "My Profile"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
        automaticallyImplyLeading: !widget.isFirstTime,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFILE HEADER
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => pickUpload(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Change Photo"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          section("Personal Details", [
            input("Name", name),
            input("Phone", phone),
            input("Address", address),
            input("Department", department),
          ]),

          if (role == 'student')
            section("Academic Details", [
              input("Gender", gender),
              input("Date of Birth", dob),
              input("Semester", semester),
              input("Duration", duration),
            ]),

          if (role == 'alumni')
            section("Professional Details", [
              input("Designation", designation),
              input("Department Studied", deptStudied),
              input("Working Address", workingAddress),
              input("Year of Passout", passoutYear),
              ElevatedButton.icon(
                onPressed: () => pickUpload(isProof: true),
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Alumni Proof"),
              ),
            ]),

          if (role == 'mentor')
            section("Mentor Details", [
              input("Semester In Charge", semInCharge),
              input("Qualification", qualification),
              input("Years of Experience", experience),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MentorEducationForm()),
                ),
                icon: const Icon(Icons.school),
                label: const Text("Education Details"),
              ),
            ]),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: saveProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("Save Profile"),
          ),

          if (!widget.isFirstTime) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()),
              ),
              child: const Text("Change Password"),
            ),
          ],
        ],
      ),
    );
  }
}
