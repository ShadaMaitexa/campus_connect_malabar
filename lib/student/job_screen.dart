import 'package:campus_connect_malabar/alumini/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/profile_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Job Openings',
        gradient: AppGradients.purple,
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppGradients.purple.colors.first.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('marketplace')
              .where('type', isEqualTo: 'job')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.work_outline_rounded,
                title: 'No Job Openings',
                subtitle: 'Check back later for new opportunities',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return AnimatedListItem(
                  index: index,
                  child: _JobCard(
                    doc: snapshot.data!.docs[index],
                    index: index,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final int index;

  const _JobCard({required this.doc, required this.index});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _isExpanded = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doc['postedBy'])
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const SizedBox(height: 180);
        }

        final user = userSnap.data!;
        final data = widget.doc.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppGradients.purple.colors.first.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
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
                    // Header with gradient
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppGradients.purple,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'Job Title',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['company'] ?? 'Company',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            data['description'] ?? 'No description',
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),

                          if (_isExpanded && data['requirements'] != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Requirements',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['requirements'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],

                          const Divider(height: 32),

                          // User info
                          Row(
                            children: [
                              // Avatar
                              Hero(
                                tag: 'avatar_${user.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppGradients.purple,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppGradients.purple.colors.first
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: user['photoUrl'] != null &&
                                            user['photoUrl']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(user['photoUrl'])
                                        : null,
                                    child: (user['photoUrl'] == null ||
                                            user['photoUrl'].toString().isEmpty)
                                        ? Text(
                                            user['name'][0].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name and role
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'] ?? 'User',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppGradients.purple.colors.first
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        user['role']
                                            .toString()
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppGradients.purple.colors.first,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              Row(
                                children: [
                                  _ActionButton(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Profile',
                                    gradient: AppGradients.blue,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProfileScreen(userId: user.id),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionButton(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    label: 'Chat',
                                    gradient: AppGradients.success,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            userId: user.id,
                                            name: user['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
