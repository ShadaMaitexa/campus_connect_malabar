import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../services/firestore_service.dart';

class PostEvent extends StatefulWidget {
  const PostEvent({super.key});

  @override
  State<PostEvent> createState() => _PostEventState();
}

class _PostEventState extends State<PostEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firestore = FirestoreService();
  
  DateTime _eventDate = DateTime.now();
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _postEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userData = user != null ? await _firestore.getUserData(user.uid) : null;

      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'date': Timestamp.fromDate(_eventDate),
        'department': _selectedDepartment,
        'postedBy': userData?['name'] ?? 'Admin',
        'role': 'admin',
        'createdAt': Timestamp.now(),
      });

      _titleController.clear();
      _descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event posted successfully'),
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
              Text('Post Event', style: AppTheme.heading1),
              const SizedBox(height: AppTheme.spacingXL),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Event Title',
                      hint: 'Enter event title',
                      prefixIcon: Icons.event_rounded,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter event title' : null,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Event Description',
                      hint: 'Enter event description',
                      prefixIcon: Icons.description_rounded,
                      maxLines: 4,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter event description'
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    AppTextField(
                      label: 'Event Date',
                      hint: _eventDate.toLocal().toString().split(' ')[0],
                      prefixIcon: Icons.calendar_today_rounded,
                      enabled: false,
                      onSuffixTap: _selectDate,
                      suffixIcon: Icons.calendar_month_rounded,
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
                      label: 'Post Event',
                      onPressed: _isLoading ? null : _postEvent,
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
