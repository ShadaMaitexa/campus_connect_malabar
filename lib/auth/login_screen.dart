import 'package:campus_connect_malabar/library/library_admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_dashboard.dart';

import '../utils/animations.dart';
import '../widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../routing/role_router.dart';
import '../profile/profile_screen.dart';
import 'forgot_screen.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String? message;
  const LoginScreen({super.key, this.message});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == "admin@campusconnect.com" && password == "admin123") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      return;
    }

    if (email == "library@campusconnect.com" && password == "library123") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryAdminDashboard()));
      return;
    }

    final success = await authProvider.login(email, password);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userModel = authProvider.userModel;
    if (userModel == null) return;

    if ((userModel.role == 'mentor' || userModel.role == 'alumni') && !userModel.approved) {
      await authProvider.logout();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Waiting for admin approval'), backgroundColor: AppTheme.warningColor));
      return;
    }

    if (!userModel.profileCompleted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RoleRouter(role: userModel.role)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side: Branding & Image
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(60),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 32),
                Text(
                  "Empowering Your\nCampus Journey.",
                  style: GoogleFonts.outfit(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Join the most advanced ecosystem for education management and collaboration.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Side: Login Form
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.darkSurface,
            padding: const EdgeInsets.all(60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  "Campus Connect",
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: _buildLoginForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final authProvider = Provider.of<AuthProvider>(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Login",
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Welcome back, please enter your details.",
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 48),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'email@example.com',
            prefixIcon: Icons.email_rounded,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_rounded,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: Text("Forgot Password?", style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New here?", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
