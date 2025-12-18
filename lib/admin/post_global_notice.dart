import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../services/firestore_service.dart';

class AdminPostNotice extends StatefulWidget {
  const AdminPostNotice({super.key});

  @override
  State<AdminPostNotice> createState() => _AdminPostNoticeState();
}

class _AdminPostNoticeState extends State<AdminPostNotice> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _firestore = FirestoreService();
  
  String _selectedDepartment = 'ALL';
  List<String> _departments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final depts = await _firestore.getDepartments();
    setState(() {
      _departments = ['ALL', ...depts];
    });
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userData = user != null ? await _firestore.getUserData(user.uid) : null;

      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'department': _selectedDepartment,
        'postedBy': userData?['name'] ?? 'Admin',
        'role': 'admin',
        'createdAt': Timestamp.now(),
      });

      _titleController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notice posted successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post Notice', style: AppTheme.heading1),
              const SizedBox(height: AppTheme.spacingXL),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Notice Title',
                      hint: 'Enter notice title',
                      prefixIcon: Icons.title_rounded,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter notice title' : null,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    AppTextField(
                      controller: _messageController,
                      label: 'Notice Message',
                      hint: 'Enter notice message',
                      prefixIcon: Icons.message_rounded,
                      maxLines: 6,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter notice message'
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.apartment_rounded),
                      ),
                      items: _departments
                          .map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDepartment = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingXL),
                    AppButton(
                      label: 'Post Notice',
                      onPressed: _isLoading ? null : _postNotice,
                      isLoading: _isLoading,
                      width: Responsive.isMobile(context) ? double.infinity : 200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
