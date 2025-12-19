import 'package:campus_connect_malabar/routing/role_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ProfileScreen extends StatefulWidget {
  /// OPTIONAL — keeps compatibility with old navigation
  final bool? isFirstTime;
  final String? userId;

  const ProfileScreen({
    super.key,
    this.isFirstTime,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final departmentController = TextEditingController();
  final dobController = TextEditingController();

  String? gender;
  DateTime? selectedDob;
  bool isSaving = false;

  late final String uid;

  @override
  void initState() {
    super.initState();

    /// SAFELY resolve UID
    uid = widget.userId ??
        FirebaseAuth.instance.currentUser!.uid;

    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    departmentController.dispose();
    dobController.dispose();
    super.dispose();
  }

  // ---------------- LOAD PROFILE ----------------
  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      departmentController.text = data['department'] ?? '';
      gender = data['gender'];
      dobController.text = data['dob'] ?? '';
    });
  }

  // ---------------- DOB PICKER ----------------
  Future<void> pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDob ?? DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDob = picked;
        dobController.text =
            "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select gender")),
      );
      return;
    }

    setState(() => isSaving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "department": departmentController.text.trim(),
      "gender": gender,
      "dob": dobController.text,
      "profileCompleted": true,
    }, SetOptions(merge: true));

    setState(() => isSaving = false);

    /// REDIRECT ONLY IF FIRST TIME
    if (widget.isFirstTime == true) {
      _redirectToDashboard();
    } else {
      Navigator.pop(context);
    }
  }

  // ---------------- REDIRECT ----------------
  Future<void> _redirectToDashboard() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final role = doc['role'];

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => RoleRouter(role: role),
      ),
      (_) => false,
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: "Department"),
              ),
              const SizedBox(height: 16),

              const Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  _genderRadio("Male"),
                  _genderRadio("Female"),
                  _genderRadio("Other"),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickDob,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveProfile,
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- GENDER RADIO ----------------
  Widget _genderRadio(String value) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: gender,
        title: Text(value),
        dense: true,
        contentPadding: EdgeInsets.zero,
        onChanged: (val) => setState(() => gender = val),
      ),
    );
  }
}
