import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer.dart';

class ApproveUsers extends StatelessWidget {
  const ApproveUsers({super.key});

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
            Text('Pending User Approvals', style: AppTheme.heading1),
            const SizedBox(height: AppTheme.spacingL),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('approved', isEqualTo: false)
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
                          height: 100,
                        ),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.verified_user_rounded,
                    title: 'No pending approvals',
                    message: 'All users have been approved',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingM),
                  itemBuilder: (context, index) {
                    final user = docs[index];
                    return _UserApprovalCard(user: user);
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

class _UserApprovalCard extends StatelessWidget {
  final QueryDocumentSnapshot user;

  const _UserApprovalCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'student';
    final name = user['name'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final department = user['department'] as String? ?? '';

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Responsive.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTheme.heading3),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(email, style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    _InfoChip(label: role.toUpperCase()),
                    const SizedBox(width: AppTheme.spacingS),
                    _InfoChip(label: department),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Approve',
                    onPressed: () => _approveUser(context),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTheme.heading3),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(email, style: AppTheme.bodyMedium),
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          _InfoChip(label: role.toUpperCase()),
                          const SizedBox(width: AppTheme.spacingS),
                          _InfoChip(label: department),
                        ],
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Approve',
                  onPressed: () => _approveUser(context),
                ),
              ],
            ),
    );
  }

  Future<void> _approveUser(BuildContext context) async {
    try {
      await user.reference.update({'approved': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User approved successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
