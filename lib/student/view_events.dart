import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/loading_shimmer.dart';

class ViewEvents extends StatelessWidget {
  const ViewEvents({super.key});

  Future<String> getUserDepartment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc['department'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: CustomAppBar(title: "Events", gradient: AppGradients.info),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.03),
              isDark ? AppTheme.darkBackground : Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<String>(
          future: getUserDepartment(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final department = snapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snap.data!.docs.where((doc) {
                  return doc['department'] == 'ALL' ||
                      doc['department'] == department;
                }).toList();

                if (events.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.event_busy_rounded,
                    title: "No upcoming events",
                    subtitle: "Check back later for new announcements",
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = events[index];
                    final dateTime = (doc['date'] as Timestamp).toDate();
                    final isUpcoming = dateTime.isAfter(DateTime.now());

                    return AppAnimations.slideInFromBottom(
                      delay: Duration(milliseconds: 100 + (index * 50)),
                      child: _eventCard(
                        context,
                        doc,
                        dateTime,
                        isUpcoming,
                        isDark,
                      ),
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

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy_rounded, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No upcoming events",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- EVENT CARD ----------------
  Widget _eventCard(
    BuildContext context,
    QueryDocumentSnapshot doc,
    DateTime dateTime,
    bool isUpcoming,
    bool isDark,
  ) {
    final date =
        "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
    final role = doc['role'].toString().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isUpcoming
            ? const LinearGradient(
                colors: [Color(0xFFEFF2FF), Color(0xFFE0E7FF)],
              )
            : LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade50],
              ),
        border: Border.all(
          color: isUpcoming
              ? const Color(0xFF4B6CB7).withOpacity(0.35)
              : Colors.grey.shade300,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isUpcoming
                      ? const LinearGradient(
                          colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.green : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            doc['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            doc['description'],
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 16),

          // Date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
