import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer.dart';

class ManageDepartments extends StatefulWidget {
  const ManageDepartments({super.key});

  @override
  State<ManageDepartments> createState() => _ManageDepartmentsState();
}

class _ManageDepartmentsState extends State<ManageDepartments> {
  final _deptController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addDepartment() async {
    if (_deptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a department name'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('departments').add({
        'name': _deptController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _deptController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Department added successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
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

  Future<void> _deleteDepartment(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: const Text('Are you sure you want to delete this department?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('departments')
            .doc(docId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Department deleted successfully'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Departments', style: AppTheme.heading1),
            const SizedBox(height: AppTheme.spacingXL),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Department', style: AppTheme.heading3),
                  const SizedBox(height: AppTheme.spacingL),
                  AppTextField(
                    controller: _deptController,
                    label: 'Department Name',
                    hint: 'Enter department name',
                    prefixIcon: Icons.apartment_rounded,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  AppButton(
                    label: 'Add Department',
                    onPressed: _isLoading ? null : _addDepartment,
                    isLoading: _isLoading,
                    width: Responsive.isMobile(context) ? double.infinity : 200,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text('All Departments', style: AppTheme.heading2),
            const SizedBox(height: AppTheme.spacingL),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('departments')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                        child: LoadingShimmer(
                          width: double.infinity,
                          height: 80,
                        ),
                      ),
                    ),
                  );
                }

                final departments = snapshot.data!.docs;

                if (departments.isEmpty) {
                  return const EmptyState(
                    icon: Icons.apartment_rounded,
                    title: 'No departments',
                    message: 'Add your first department to get started',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: departments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingM),
                  itemBuilder: (context, index) {
                    final dept = departments[index];
                    return _DepartmentCard(
                      name: dept['name'] as String,
                      onDelete: () => _deleteDepartment(dept.id),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final String name;
  final VoidCallback onDelete;

  const _DepartmentCard({
    required this.name,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              Icons.apartment_rounded,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Text(name, style: AppTheme.heading3),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            onPressed: onDelete,
            tooltip: 'Delete department',
          ),
        ],
      ),
    );
  }
}
