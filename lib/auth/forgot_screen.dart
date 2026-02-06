import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

import '../utils/animations.dart';
import '../widgets/app_text_field.dart';
import '../widgets/dashboard_card.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (authProvider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent. Please check your inbox.'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: AppEffects.deepShadow,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 48),
                      const SizedBox(height: 24),
                      _buildResetForm(authProvider),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reset Password",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your email to receive a reset link",
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 40),
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'email@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.contains('@') ?? false ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send Reset Link", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
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
