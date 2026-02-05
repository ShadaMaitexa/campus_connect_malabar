import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../auth/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic, // Smooth curve for scrolling
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: _buildAnimatedBackground(),
          ),
          
          // Main Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _HeroSection(onStart: () => _scrollTo(900)),
                const _StatsSection(),
                const _FeaturesSection(),
                const _HowItWorksSection(),
                const _FooterSection(),
              ],
            ),
          ),

          // Navbar
          _Navbar(scrollOffset: _scrollOffset),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            Color(0xFF0F172A),
            AppTheme.darkBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  final double scrollOffset;

  const _Navbar({required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final isScrolled = scrollOffset > 50;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 20),
      decoration: BoxDecoration(
        color: isScrolled ? AppTheme.darkSurface.withOpacity(0.8) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled ? AppTheme.darkBorder : Colors.transparent,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              // Brand
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppEffects.subtleShadow,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Campus Connect",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isDesktop) ...[
                _NavLink(label: "Solutions", onTap: () {}),
                _NavLink(label: "Features", onTap: () {}),
                _NavLink(label: "Resources", onTap: () {}),
                const SizedBox(width: 32),
              ],
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.darkBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onStart;

  const _HeroSection({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      height: size.height,
      width: double.infinity,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 20),
          child: Row(
            children: [
              Expanded(
                flex: isDesktop ? 6 : 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: AppTheme.accentColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "NEW: V2.0 Dashboard is now live",
                            style: GoogleFonts.inter(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Elevate Your\nCampus Experience",
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: isDesktop ? 80 : 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "A unified ecosystem for students, alumni, and administration. Management, communication, and growth - all in one hyper-connected platform.",
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Explore Solutions"),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text("Watch Demo", style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Container(
                      height: 500,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48),
                        gradient: AppGradients.surface,
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 100,
                            spreadRadius: -20,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(Icons.phone_iphone_rounded, size: 120, color: Colors.white10),
                            ),
                            Positioned(
                              top: 40,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 80,
                                decoration: AppEffects.glassDecoration,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Wrap(
        spacing: 60,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: const [
          _StatTile(number: "15k+", label: "Daily Active Users"),
          _StatTile(number: "50+", label: "Partner Institutions"),
          _StatTile(number: "99.9%", label: "Uptime Reliability"),
          _StatTile(number: "24/7", label: "Premium Support"),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String number;
  final String label;

  const _StatTile({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.outfit(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
      child: Column(
        children: [
          Text(
            "Hyper-Efficient Features",
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Precision-engineered for modern campus needs.",
            style: GoogleFonts.inter(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 80),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 1,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            childAspectRatio: 1.4,
            children: const [
              _FeatureItem(
                icon: Icons.admin_panel_settings_rounded,
                title: "Centralized Admin",
                description: "Full visibility and control over campus operations with real-time analytics.",
                gradient: AppGradients.primary,
              ),
              _FeatureItem(
                icon: Icons.library_books_rounded,
                title: "Smart Library",
                description: "Digital inventory management, automated fines, and resource tracking.",
                gradient: AppGradients.accent,
              ),
              _FeatureItem(
                icon: Icons.hub_rounded,
                title: "Alumni Hub",
                description: "Bridge the gap between current students and successful graduates.",
                gradient: AppGradients.success,
              ),
              _FeatureItem(
                icon: Icons.psychology_rounded,
                title: "Mentor Link",
                description: "Facilitate meaningful mentor-student interactions seamlessly.",
                gradient: AppGradients.surface,
              ),
              _FeatureItem(
                icon: Icons.assignment_turned_in_rounded,
                title: "Aptitude Engine",
                description: "Prepare students for the industry with integrated assessment tools.",
                gradient: AppGradients.primary,
              ),
              _FeatureItem(
                icon: Icons.rocket_launch_rounded,
                title: "Placement Portal",
                description: "Streamline the hiring process for companies and students alike.",
                gradient: AppGradients.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(description, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), height: 1.5)),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
      color: AppTheme.darkSurface.withOpacity(0.5),
      child: Column(
        children: [
          Text(
            "Simplified Workflow",
            style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 80),
          Wrap(
            spacing: 80,
            runSpacing: 60,
            alignment: WrapAlignment.center,
            children: const [
              _StepProgress(num: "01", title: "Join", desc: "Select your role and authenticate safely."),
              _StepProgress(num: "02", title: "Sync", desc: "Access your personalized campus dashboard."),
              _StepProgress(num: "03", title: "Scale", desc: "Utilize resources to grow and collaborate."),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final String num;
  final String title;
  final String desc;

  const _StepProgress({required this.num, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Text(
            num,
            style: GoogleFonts.outfit(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Text(desc, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialBtn(icon: Icons.code_rounded),
              _SocialBtn(icon: Icons.terminal_rounded),
              _SocialBtn(icon: Icons.webhook_rounded),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "© 2024 Campus Connect Systems. Enterprise Architecture Ready.",
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  const _SocialBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Icon(icon, color: Colors.white54, size: 20),
    );
  }
}
