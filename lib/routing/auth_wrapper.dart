import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/auth_provider.dart';
import '../auth/splash_screen.dart';
import '../auth/login_screen.dart';
import '../routing/role_router.dart';
import '../profile/profile_screen.dart';
import '../web/landing_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return kIsWeb ? const LandingPage() : const SplashScreen();
        }

        final userModel = authProvider.userModel;
        if (userModel == null) {
          return const LoginScreen();
        }

        // Check approval for mentor/alumni
        if ((userModel.role == 'mentor' || userModel.role == 'alumni') &&
            !userModel.approved) {
          return LoginScreen(message: 'Your account is pending admin approval');
        }

        // Check profile completion
        if (!userModel.profileCompleted) {
          return const ProfileScreen();
        }

        return RoleRouter(role: userModel.role);
      },
    );
  }
}
