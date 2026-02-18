import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: PopupMenuButton<String>(
        color: AppTheme.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.darkSurface,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ),
        onSelected: (value) async {
          if (value == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(isFirstTime: false),
              ),
            );
          }

          if (value == 'logout') {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkSurface,
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  "Are you sure you want to exit?",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: ListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white70,
              ),
              title: Text(
                'My Profile',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}
