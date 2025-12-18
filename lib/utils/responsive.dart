import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTheme.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppTheme.tabletBreakpoint;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTheme.tabletBreakpoint;
  
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
  
  static double padding(BuildContext context) => value(
    context,
    mobile: AppTheme.spacingM,
    tablet: AppTheme.spacingL,
    desktop: AppTheme.spacingXL,
  );
  
  static int gridCrossAxisCount(BuildContext context) => value(
    context,
    mobile: 2,
    tablet: 3,
    desktop: 4,
  );
  
  static double maxContentWidth(BuildContext context) => value(
    context,
    mobile: double.infinity,
    tablet: 800,
    desktop: 1200,
  );
}

