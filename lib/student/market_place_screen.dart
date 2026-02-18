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
    return Theme(
      data: AppTheme.darkTheme,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppTheme.darkBackground,
          appBar: const CustomAppBar(
            title: 'Marketplace',
            subtitle: 'Campus Trade & Careers',
            gradient: AppGradients.orange,
            showBackButton: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppGradients.orange.colors.first.withOpacity(0.05),
                  AppTheme.darkBackground,
                ],
              ),
            ),
            child: Column(
              children: [
                // Refined Custom Tab Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        gradient: AppGradients.orange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppGradients.orange.colors.first.withOpacity(
                              0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorPadding: const EdgeInsets.all(4),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white38,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.menu_book_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('MATERIALS'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.work_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('JOBS'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab Views
                const Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: [StudyMaterialsScreen(), JobsScreen()],
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
