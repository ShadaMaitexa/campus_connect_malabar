import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../widgets/loading_shimmer.dart';

class ViewEvents extends StatelessWidget {
  const ViewEvents({super.key});

  Future<String?> getUserDepartment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['department'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(
        title: "Upcoming Events",
        gradient: AppGradients.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: FutureBuilder<String?>(
          future: getUserDepartment(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final department = snapshot.data;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(itemCount: 3);
                }

                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.event_busy_rounded,
                    title: "No upcoming events",
                    subtitle: "Check back later for new announcements",
                  );
                }

                final events = snap.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['department'] == 'ALL' ||
                      data['department'] == department;
                }).toList();

                if (events.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.event_busy_rounded,
                    title: "No events for you",
                    subtitle:
                        "There are no events scheduled for your department",
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final doc = events[index];
                    return AppAnimations.slideInFromBottom(
                      delay: Duration(milliseconds: 100 + (index * 50)),
                      child: _EventCard(doc: doc),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _EventCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final dateTime = (data['date'] as Timestamp).toDate();
    final isUpcoming = dateTime.isAfter(DateTime.now());
    final dateStr =
        "${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year}";
    final role = (data['role'] ?? 'OFFICIAL').toString().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUpcoming
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event_available_rounded,
                          color: isUpcoming
                              ? AppTheme.primaryColor
                              : Colors.white54,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: isUpcoming
                              ? AppGradients.success
                              : AppGradients.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data['title'] ?? 'Event',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.darkTextSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Chip(icon: Icons.calendar_today_rounded, label: dateStr),
                      const SizedBox(width: 12),
                      if (data['venue'] != null)
                        _Chip(
                          icon: Icons.location_on_rounded,
                          label: data['venue'],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
