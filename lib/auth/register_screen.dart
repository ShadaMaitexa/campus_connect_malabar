import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

import '../utils/animations.dart';
import '../widgets/app_text_field.dart';
import '../widgets/dashboard_card.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  String _role = 'student';
 
  bool _obscurePassword = true;
 
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;


    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _role
     
    );

    if (!mounted) return;

    if (success) {
      await authProvider.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _role == 'student'
                ? "Registration successful. Please login."
                : "Registration successful. Await admin approval.",
          ),
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
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 0 : 20,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                child: isDesktop ? _buildDesktopLayout(authProvider) : _buildMobileLayout(authProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: AppEffects.deepShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 32),
                  Text(
                    "Join the\nCommunity",
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Unlock exclusive campus resources, connect with mentors, and accelerate your growth.",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: _buildRegisterForm(authProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 48),
          const SizedBox(height: 24),
          _buildRegisterForm(authProvider),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Account",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start your journey today",
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 40),
          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'email@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.contains('@') ?? false ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (value) => (value?.length ?? 0) < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 24),
          Text(
            'JOIN AS',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildRoleSelector(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
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

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _role.toUpperCase(),
          isExpanded: true,
          dropdownColor: AppTheme.darkSurface,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
          items: ['STUDENT', 'MENTOR', 'ALUMNI'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (v) => setState(() => _role = v!.toLowerCase()),
        ),
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
