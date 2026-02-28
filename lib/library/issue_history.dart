import 'package:campus_connect_malabar/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class IssueHistoryScreen extends StatefulWidget {
  final bool isEmbedded;
  final bool showOnlyActive;
  const IssueHistoryScreen({
    super.key,
    this.isEmbedded = false,
    this.showOnlyActive = false,
  });

  @override
  State<IssueHistoryScreen> createState() => _IssueHistoryScreenState();
}

class _IssueHistoryScreenState extends State<IssueHistoryScreen> {
  late bool _showOnlyActive;

  @override
  void initState() {
    super.initState();
    _showOnlyActive = widget.showOnlyActive;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildBodyContent(context);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/generated_background.png",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: AppTheme.darkBackground.withOpacity(0.92)),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: _buildBodyContent(context),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        _showOnlyActive ? "Active Issues" : "Issue History",
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterToggle(
                  label: "Active",
                  isSelected: _showOnlyActive,
                  onTap: () => setState(() => _showOnlyActive = true),
                ),
                _FilterToggle(
                  label: "All",
                  isSelected: !_showOnlyActive,
                  onTap: () => setState(() => _showOnlyActive = false),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBodyContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.isEmbedded)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showOnlyActive ? "Active Issues" : "Issued Books",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FilterToggle(
                          label: "Active",
                          isSelected: _showOnlyActive,
                          onTap: () => setState(() => _showOnlyActive = true),
                        ),
                        _FilterToggle(
                          label: "All",
                          isSelected: !_showOnlyActive,
                          onTap: () => setState(() => _showOnlyActive = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        StreamBuilder<QuerySnapshot>(
            stream: _showOnlyActive
                ? FirebaseFirestore.instance
                    .collection('issued_books')
                    .where('returned', isEqualTo: false)
                    .orderBy('issuedAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('issued_books')
                    .orderBy('issuedAt', descending: true)
                    .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error: ${snap.error}", style: const TextStyle(color: Colors.red))),
                );
              }
              if (!snap.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(100),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snap.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(100),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            _showOnlyActive
                                ? Icons.check_circle_outline_rounded
                                : Icons.history_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showOnlyActive
                                ? "No Active Issues"
                                : "No Issue History",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = snap.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isReturned = data['returned'] == true;
                    final issuedAt = (data['issuedAt'] as Timestamp).toDate();
                    final dueDate = (data['returnDate'] as Timestamp).toDate();
                    final isOverdue = !isReturned && DateTime.now().isAfter(dueDate);

                    return AppAnimations.slideInFromBottom(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isOverdue 
                                ? Colors.red.withOpacity(0.2) 
                                : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (isReturned
                                            ? Colors.green
                                            : isOverdue ? Colors.red : Colors.orange)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isReturned
                                        ? Icons.check_circle_rounded
                                        : isOverdue ? Icons.warning_rounded : Icons.pending_actions_rounded,
                                    color: isReturned
                                        ? Colors.greenAccent
                                        : isOverdue ? Colors.redAccent : Colors.orangeAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['bookTitle'] ?? "Unknown Book",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance.collection('users').doc(data['studentId']).get(),
                                        builder: (context, userSnap) {
                                          final name = userSnap.hasData ? (userSnap.data!.data() as Map<String, dynamic>?)?['name'] ?? 'Unknown' : 'Loading...';
                                          return Row(
                                            children: [
                                              Icon(Icons.person_outline_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
                                              const SizedBox(width: 4),
                                              Text(
                                                name,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white.withOpacity(0.4),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusBadge(isReturned: isReturned, isOverdue: isOverdue),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.05), height: 1),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _DateInfo(
                                  label: "Issued On",
                                  date: issuedAt,
                                  color: Colors.white60,
                                ),
                                _DateInfo(
                                  label: isReturned ? "Returned On" : "Due Date",
                                  date: isReturned && data.containsKey('returnedAt') 
                                      ? (data['returnedAt'] as Timestamp).toDate()
                                      : dueDate,
                                  color: isOverdue ? Colors.redAccent : (isReturned ? Colors.greenAccent : Colors.white60),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: snap.data!.docs.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isReturned;
  final bool isOverdue;

  const _StatusBadge({required this.isReturned, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    String label = isReturned ? "RETURNED" : (isOverdue ? "OVERDUE" : "PENDING");
    Color color = isReturned ? Colors.green : (isOverdue ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color.withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;

  const _DateInfo({required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date.toString().split(' ')[0],
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

