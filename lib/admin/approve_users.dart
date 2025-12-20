import 'package:campus_connect_malabar/services/approve_user_service.dart';
import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
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
    return Scaffold(
      appBar: CustomAppBar(
        title: "Pending User Approvals",
        showBackButton: true,
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('approved', isEqualTo: false)
                .where('role', whereIn: ['mentor', 'alumni']) // ✅ IMPORTANT
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverPadding(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacingM,
                            ),
                            child: LoadingShimmer(
                              width: double.infinity,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.verified_user_rounded,
                    title: "No Pending Approvals",
                    subtitle: "All mentors and alumni are approved.",
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(Responsive.padding(context)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return AppAnimations.slideInFromBottom(
                      child: Column(
                        children: [
                          _UserApprovalCard(user: docs[index]),
                          if (index < docs.length - 1)
                            const SizedBox(height: AppTheme.spacingM),
                        ],
                      ),
                    );
                  }, childCount: docs.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- USER CARD ----------------
class _UserApprovalCard extends StatelessWidget {
  final QueryDocumentSnapshot user;

  const _UserApprovalCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] ?? '';
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Responsive.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(name, email),
                const SizedBox(height: AppTheme.spacingM),

                AppButton(label: 'Approve', onPressed: () => _approve(context)),
              ],
            )
          : Row(
              children: [
                _avatar(name),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTheme.heading3),
                      Text(email, style: AppTheme.bodyMedium),
                      const SizedBox(height: AppTheme.spacingXS),
                    ],
                  ),
                ),
                AppButton(label: 'Approve', onPressed: () => _approve(context)),
              ],
            ),
    );
  }

  Widget _avatar(String name) => CircleAvatar(
    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
      style: TextStyle(color: AppTheme.primaryColor),
    ),
  );

  Widget _header(String name, String email) => Row(
    children: [
      _avatar(name),
      const SizedBox(width: AppTheme.spacingM),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTheme.heading3),
            Text(email, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    ],
  );

  Widget _chips(String role, String dept) => Row(
    children: [
      _InfoChip(label: role.toUpperCase()),
      const SizedBox(width: AppTheme.spacingS),
      if (dept.isNotEmpty) _InfoChip(label: dept),
    ],
  );

  Future<void> _approve(BuildContext context) async {
    await ApproveUserService.approveUser(
      userId: user.id,
      role: user['role'],
      name: user['name'],
      email: user['email'],
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User approved successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}

// ---------------- CHIP ----------------
class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
