import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color primaryColor = Color(0xFF6366F1); // Modern Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF020617); // Deepest Navy
  static const Color darkSurface = Color(0xFF0F172A); // Slate 900
  static const Color darkSurfaceSecondary = Color(0xFF1E293B); // Slate 800
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // --- Spacing ---
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // --- Border Radius ---
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // --- Breakpoints ---
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // --- Typography ---
  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get heading3 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal);

  static TextStyle get button =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);

  // --- Themes ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: lightSurface,
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        outline: lightBorder,
      ),
      scaffoldBackgroundColor: lightBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: heading1.copyWith(color: lightTextPrimary),
        displayMedium: heading2.copyWith(color: lightTextPrimary),
        displaySmall: heading3.copyWith(color: lightTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: lightTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: lightTextSecondary),
        bodySmall: bodySmall.copyWith(color: lightTextSecondary),
        labelLarge: button.copyWith(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: lightBackground.withOpacity(0.8),
        foregroundColor: lightTextPrimary,
        titleTextStyle: heading3.copyWith(color: lightTextPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: lightBorder),
        ),
        color: lightSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(spacingM),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: button,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: heading1.copyWith(color: darkTextPrimary),
        displayMedium: heading2.copyWith(color: darkTextPrimary),
        displaySmall: heading3.copyWith(color: darkTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: darkTextSecondary),
        bodySmall: bodySmall.copyWith(color: darkTextSecondary),
        labelLarge: button.copyWith(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkBackground.withOpacity(0.8),
        foregroundColor: darkTextPrimary,
        titleTextStyle: heading3.copyWith(color: darkTextPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: darkBorder),
        ),
        color: darkSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(spacingM),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: button,
        ),
      ),
    );
  }
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondary = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accent = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surface = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const danger = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const info = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const teal = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purple = LinearGradient(
    colors: [Color(0xFFD946EF), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const orange = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dark = LinearGradient(
    colors: [Color(0xFF334155), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blue = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunset = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ocean = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glass = LinearGradient(
    colors: [Colors.white24, Colors.white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppEffects {
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get deepShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      );
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTheme.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppTheme.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTheme.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppTheme.tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= AppTheme.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
