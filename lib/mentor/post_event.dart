import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          content: Text("Please fill all fields and select a date"),
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
          const SnackBar(content: Text("Event posted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: CustomAppBar(title: "Post Event", gradient: AppGradients.success),
      body: SingleChildScrollView(
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
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Create an Event",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "This event will be visible to all students in your department.",
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(height: 32),

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

                    const Text(
                      "Event Date",
                      style: TextStyle(
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
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: AppTheme.darkSurface,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => eventDate = picked);
                        }
                      },
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
                                : AppTheme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: eventDate == null
                                  ? Colors.white38
                                  : AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              eventDate == null
                                  ? "Select Date"
                                  : "${eventDate!.day}/${eventDate!.month}/${eventDate!.year}",
                              style: TextStyle(
                                color: eventDate == null
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: eventDate == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
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
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: postEvent,
                        icon: const Icon(Icons.publish_rounded),
                        label: const Text(
                          "Schedule Event",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
