import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/widgets/dashboard_card.dart';
import 'package:campus_connect_malabar/widgets/loading_shimmer.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/app_text_field.dart';

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

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final String _userId;
  late String _role;
  bool _isLoading = true;
  bool _isSaving = false;

  // Common fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String? _email;
  String? _department;

  String gender = 'Male';
  DateTime? dob;

  // Alumni fields
  final currentPositionController = TextEditingController();
  final workingAddressController = TextEditingController();
  final passoutYearController = TextEditingController();

  // Mentor fields
  final designationController = TextEditingController();
  final semesterInChargeController = TextEditingController();

  // Change password
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool _showOldPassword = false;
  bool _showNewPassword = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
    _role = widget.role ?? 'student';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        gender = data['gender'] ?? 'Male';
        _email = data['email'];
        _department = data['department'];

        if (data['dob'] != null) {
          dob = (data['dob'] as Timestamp).toDate();
        }

        _role = widget.role ?? data['role'] ?? 'student';

        // Alumni
        currentPositionController.text = data['currentPosition'] ?? '';
        workingAddressController.text = data['workingAddress'] ?? '';
        passoutYearController.text = data['passoutYear'] ?? '';

        // Mentor
        designationController.text = data['designation'] ?? '';
        semesterInChargeController.text = data['semesterInCharge'] ?? '';
      } else {
        // If no profile exists, set default values
        nameController.text = '';
        phoneController.text = '';
        addressController.text = '';
        gender = 'Male';
        _email = FirebaseAuth.instance.currentUser?.email;
        _role = widget.role ?? 'student';
      }
    } catch (e) {
      // Handle error gracefully
      nameController.text = '';
      phoneController.text = '';
      addressController.text = '';
      gender = 'Male';
      _email = FirebaseAuth.instance.currentUser?.email;
      _role = widget.role ?? 'student';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> data = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'gender': gender,
      'dob': dob,
      'role': _role,
      'profileCompleted': true,
    };

    if (_role == 'alumni') {
      data.addAll({
        'currentPosition': currentPositionController.text.trim(),
        'workingAddress': workingAddressController.text.trim(),
        'passoutYear': passoutYearController.text.trim(),
      });
    }

    if (_role == 'mentor') {
      data.addAll({
        'designation': designationController.text.trim(),
        'semesterInCharge': semesterInChargeController.text.trim(),
      });
    }

    await FirebaseFirestore.instance.collection('users').doc(_userId).set(data, SetOptions(merge: true));

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Profile updated successfully',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );

      if (widget.isFirstTime) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _changePassword() async {
    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in both password fields'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New password must be at least 6 characters'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPasswordController.text.trim());

      oldPasswordController.clear();
      newPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Password changed successfully',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password change failed. Check your current password.'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(context, isDark),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: _isLoading
                  ? const ShimmerList(itemCount: 5)
                  : _buildContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              Row(
                children: [
                  if (!widget.isFirstTime)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  if (!widget.isFirstTime) const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.isFirstTime ? 'Complete Profile' : 'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Avatar
              AppAnimations.bounce(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      nameController.text.isNotEmpty
                          ? nameController.text[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_email != null)
                Text(
                  _email!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              if (_department != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_department • ${_role.toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Details Section
          AppAnimations.slideInFromBottom(
            delay: const Duration(milliseconds: 100),
            child: _buildSectionCard(
              title: 'Basic Information',
              icon: Icons.person_rounded,
              isDark: isDark,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: addressController,
                  label: 'Address',
                  hint: 'Enter your address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Gender Selection
                _buildGenderSelector(isDark),
                const SizedBox(height: 16),
                // DOB Picker
                _buildDatePicker(isDark),
              ],
            ),
          ),

          // Role-specific fields
          if (_role == 'alumni') ...[
            const SizedBox(height: 20),
            AppAnimations.slideInFromBottom(
              delay: const Duration(milliseconds: 200),
              child: _buildSectionCard(
                title: 'Professional Details',
                icon: Icons.work_rounded,
                isDark: isDark,
                children: [
                  AppTextField(
                    controller: currentPositionController,
                    label: 'Current Position',
                    hint: 'e.g., Software Engineer',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: workingAddressController,
                    label: 'Company/Organization',
                    hint: 'Where do you work?',
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: passoutYearController,
                    label: 'Passout Year',
                    hint: 'e.g., 2020',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],

          if (_role == 'mentor') ...[
            const SizedBox(height: 20),
            AppAnimations.slideInFromBottom(
              delay: const Duration(milliseconds: 200),
              child: _buildSectionCard(
                title: 'Faculty Details',
                icon: Icons.school_rounded,
                isDark: isDark,
                children: [
                  AppTextField(
                    controller: designationController,
                    label: 'Designation',
                    hint: 'e.g., Assistant Professor',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: semesterInChargeController,
                    label: 'Semester In Charge',
                    hint: 'e.g., 4th Semester',
                    prefixIcon: Icons.class_outlined,
                  ),
                ],
              ),
            ),
          ],

          // Save Button
          const SizedBox(height: 24),
          AppAnimations.slideInFromBottom(
            delay: const Duration(milliseconds: 300),
            child: _buildSaveButton(),
          ),

          // Change Password Section
          if (!widget.isFirstTime) ...[
            const SizedBox(height: 32),
            AppAnimations.slideInFromBottom(
              delay: const Duration(milliseconds: 400),
              child: _buildSectionCard(
                title: 'Change Password',
                icon: Icons.lock_rounded,
                isDark: isDark,
                children: [
                  AppTextField(
                    controller: oldPasswordController,
                    label: 'Current Password',
                    hint: 'Enter current password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_showOldPassword,
                    suffixIcon: _showOldPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () =>
                        setState(() => _showOldPassword = !_showOldPassword),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    prefixIcon: Icons.lock_reset_rounded,
                    obscureText: !_showNewPassword,
                    suffixIcon: _showNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: Text(
                        'Change Password',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderChip('Male', Icons.male_rounded, isDark),
            const SizedBox(width: 12),
            _buildGenderChip('Female', Icons.female_rounded, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String value, IconData icon, bool isDark) {
    final isSelected = gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? AppTheme.darkSurface : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dob ?? DateTime(2000),
          firstDate: DateTime(1960),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppTheme.primaryColor,
                  onPrimary: Colors.white,
                  surface: isDark ? AppTheme.darkSurface : Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => dob = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dob == null
                    ? 'Select Date of Birth'
                    : '${dob!.day}/${dob!.month}/${dob!.year}',
                style: GoogleFonts.poppins(
                  color: dob == null
                      ? (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _saveProfile,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Save Profile',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
