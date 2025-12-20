import 'package:campus_connect_malabar/profile/change_password.dart';
import 'package:campus_connect_malabar/routing/role_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final bool? isFirstTime;
  final String? userId;

  const ProfileScreen({super.key, this.isFirstTime, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final departmentController = TextEditingController();
  final dobController = TextEditingController();

  // Student-only
  final semesterController = TextEditingController();
  final durationController = TextEditingController();

  String? gender;
  DateTime? selectedDob;
  bool isSaving = false;

  late final String uid;
  String? role;

  @override
  void initState() {
    super.initState();
    uid = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    departmentController.dispose();
    dobController.dispose();
    semesterController.dispose();
    durationController.dispose();
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
      role = data['role'];
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      departmentController.text = data['department'] ?? '';
      semesterController.text = data['semester'] ?? '';
      durationController.text = data['duration'] ?? '';
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
        dobController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select gender")));
      return;
    }

    setState(() => isSaving = true);

    final data = {
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "department": departmentController.text.trim(),
      "gender": gender,
      "dob": dobController.text,
      "profileCompleted": true,
    };

    // Student-only fields
    if (role == 'student') {
      data["semester"] = semesterController.text.trim();
      data["duration"] = durationController.text.trim();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));

    setState(() => isSaving = false);

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
      MaterialPageRoute(builder: (_) => RoleRouter(role: role)),
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
              _field(nameController, "Name", required: true),
              _field(phoneController, "Phone", required: true),
              _field(addressController, "Address"),
              _field(departmentController, "Department"),

              // -------- STUDENT ONLY --------
              if (role == 'student') ...[
                _field(semesterController, "Semester"),
                _field(durationController, "Course Duration"),
              ],

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

              _dobField(),
              const SizedBox(height: 24),

              // -------- SAVE BUTTON (FIXED) --------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Profile",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // -------- CHANGE PASSWORD --------
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                    );
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("Change Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v!.isEmpty ? "Required" : null : null,
      ),
    );
  }

  Widget _dobField() {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Date of Birth",
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: pickDob,
    );
  }

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
