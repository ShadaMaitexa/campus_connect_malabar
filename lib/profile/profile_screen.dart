import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String? role;
  final bool isFirstTime;

  const ProfileScreen({
    super.key,
    this.userId,
    this.role,
    this.isFirstTime = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🔹 resolved values
  late final String _userId;
  late String _role;

  // 🔹 Common fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String gender = 'Male';
  DateTime? dob;

  // 🔹 Alumni fields
  final currentPositionController = TextEditingController();
  final workingAddressController = TextEditingController();
  final passoutYearController = TextEditingController();

  // 🔹 Mentor fields
  final designationController = TextEditingController();
  final semesterInChargeController = TextEditingController();

  // 🔹 Change password
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userId =
        widget.userId ?? FirebaseAuth.instance.currentUser!.uid;

    _role = widget.role ?? 'student';

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    addressController.text = data['address'] ?? '';
    gender = data['gender'] ?? 'Male';

    if (data['dob'] != null) {
      dob = (data['dob'] as Timestamp).toDate();
    }

    // 🔹 If role not passed, read from Firestore
    _role = widget.role ?? data['role'] ?? 'student';

    // Alumni
    currentPositionController.text =
        data['currentPosition'] ?? '';
    workingAddressController.text =
        data['workingAddress'] ?? '';
    passoutYearController.text = data['passoutYear'] ?? '';

    // Mentor
    designationController.text = data['designation'] ?? '';
    semesterInChargeController.text =
        data['semesterInCharge'] ?? '';

    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'gender': gender,
      'dob': dob,
      'role': _role,
    };

    if (_role == 'alumni') {
      data.addAll({
        'currentPosition':
            currentPositionController.text.trim(),
        'workingAddress':
            workingAddressController.text.trim(),
        'passoutYear':
            passoutYearController.text.trim(),
      });
    }

    if (_role == 'mentor') {
      data.addAll({
        'designation':
            designationController.text.trim(),
        'semesterInCharge':
            semesterInChargeController.text.trim(),
      });
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(
        newPasswordController.text.trim(),
      );

      oldPasswordController.clear();
      newPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password change failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// 🔹 BASIC DETAILS
            TextFormField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: addressController,
              decoration:
                  const InputDecoration(labelText: 'Address'),
            ),

            const SizedBox(height: 10),

            /// 🔹 GENDER
            const Text('Gender'),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: gender,
                  onChanged: (v) =>
                      setState(() => gender = v!),
                ),
                const Text('Male'),
                Radio<String>(
                  value: 'Female',
                  groupValue: gender,
                  onChanged: (v) =>
                      setState(() => gender = v!),
                ),
                const Text('Female'),
              ],
            ),

            /// 🔹 DOB
            ListTile(
              title: Text(
                dob == null
                    ? 'Select Date of Birth'
                    : 'DOB: ${dob!.day}/${dob!.month}/${dob!.year}',
              ),
              trailing:
                  const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2005),
                  firstDate: DateTime(1960),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => dob = picked);
                }
              },
            ),

            /// 🔹 ALUMNI EXTRA
            if (_role == 'alumni') ...[
              TextFormField(
                controller: currentPositionController,
                decoration: const InputDecoration(
                    labelText: 'Current Position'),
              ),
              TextFormField(
                controller: workingAddressController,
                decoration: const InputDecoration(
                    labelText: 'Working Address'),
              ),
              TextFormField(
                controller: passoutYearController,
                decoration: const InputDecoration(
                    labelText: 'Passout Year'),
                keyboardType: TextInputType.number,
              ),
            ],

            /// 🔹 MENTOR EXTRA
            if (_role == 'mentor') ...[
              TextFormField(
                controller: designationController,
                decoration: const InputDecoration(
                    labelText: 'Designation'),
              ),
              TextFormField(
                controller: semesterInChargeController,
                decoration: const InputDecoration(
                    labelText: 'Semester In Charge'),
              ),
            ],

            const SizedBox(height: 20),

            /// 🔹 SAVE PROFILE
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),

            const Divider(height: 40),

            /// 🔹 CHANGE PASSWORD
            const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Current Password'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New Password'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
