import 'package:campus_connect_malabar/student/job_screen.dart';
import 'package:campus_connect_malabar/student/study_material_screens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../theme/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Marketplace',
          gradient: AppGradients.orange,
        ),
        body: Column(
          children: [
            // Custom Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppGradients.orange.colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      gradient: AppGradients.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppGradients.orange.colors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppGradients.orange.colors.first,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('Study Materials'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('Job Openings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Views
            const Expanded(
              child: TabBarView(
                children: [
                  StudyMaterialsScreen(),
                  JobsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
