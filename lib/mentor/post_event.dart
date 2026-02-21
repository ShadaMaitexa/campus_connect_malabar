import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_text_field.dart';
import '../utils/animations.dart';

class MentorPostEvent extends StatefulWidget {
  const MentorPostEvent({super.key});

  @override
  State<MentorPostEvent> createState() => _MentorPostEventState();
}

class _MentorPostEventState extends State<MentorPostEvent> {
  final title = TextEditingController();
  final description = TextEditingController();
  DateTime? eventDate;
  bool loading = false;

  Future<void> postEvent() async {
    if (title.text.isEmpty || description.text.isEmpty || eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Please fill all required fields and select an event date",
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final mentorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      await FirebaseFirestore.instance.collection('events').add({
        'title': title.text.trim(),
        'description': description.text.trim(),
        'date': Timestamp.fromDate(eventDate!),
        'department': mentorDoc['department'],
        'postedBy': mentorDoc['name'],
        'role': 'mentor',
        'createdAt': Timestamp.now(),
      });

      title.clear();
      description.clear();
      setState(() => eventDate = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
            content: Text("Event scheduled successfully"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
            content: Text("Error: $e"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: CustomAppBar(
          title: "Schedule Event",
          subtitle: "Plan department activities",
          gradient: AppGradients.success,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppAnimations.slideInFromBottom(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
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
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Event Details",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: title,
                          label: "Event Title",
                          prefixIcon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: description,
                          label: "Event Description",
                          prefixIcon: Icons.description_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Set Event Date *",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  eventDate ??
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppTheme.primaryColor,
                                      onPrimary: Colors.white,
                                      surface: AppTheme.darkSurface,
                                      onSurface: Colors.white,
                                    ),
                                    dialogBackgroundColor: AppTheme.darkSurface,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => eventDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: eventDate == null
                                    ? Colors.white24
                                    : AppTheme.successColor.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: eventDate == null
                                      ? Colors.white38
                                      : AppTheme.successColor,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  eventDate == null
                                      ? "Click to Choose Date"
                                      : "${eventDate!.day}/${eventDate!.month}/${eventDate!.year}",
                                  style: GoogleFonts.inter(
                                    color: eventDate == null
                                        ? Colors.white38
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: eventDate == null
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (eventDate == null)
                                  const Icon(
                                    Icons.priority_high_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppAnimations.slideInFromBottom(
                  delay: const Duration(milliseconds: 200),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: postEvent,
                            icon: const Icon(Icons.publish_rounded),
                            label: Text(
                              "Schedule Event",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.successColor.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
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
