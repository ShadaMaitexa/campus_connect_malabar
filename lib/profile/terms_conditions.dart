import 'package:flutter/material.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle("Introduction"),
            _paragraph(
              "Campus Connect is a digital academic platform designed to "
              "facilitate communication, collaboration, and resource sharing "
              "among students, mentors, alumni, and administrators. "
              "By using this platform, you agree to comply with the terms "
              "outlined below.",
            ),

            _sectionTitle("Acceptable Use"),
            _bullet(
              "This system is strictly intended for academic and institutional use only."
            ),
            _bullet(
              "Users must not misuse the platform for unauthorized, illegal, or harmful activities."
            ),
            _bullet(
              "Any attempt to manipulate data, impersonate users, or disrupt system functionality is prohibited."
            ),

            _sectionTitle("Data Privacy & Security"),
            _bullet(
              "User data is collected solely for academic and administrative purposes."
            ),
            _bullet(
              "Sharing of login credentials or sensitive personal information is strictly discouraged."
            ),
            _bullet(
              "Administrators reserve the right to monitor activities to ensure compliance and security."
            ),

            _sectionTitle("Marketplace Usage"),
            _bullet(
              "The student marketplace is a voluntary feature provided for peer-to-peer exchange of academic materials."
            ),
            _bullet(
              "Campus Connect does not take responsibility for transactions, disputes, or losses arising from marketplace usage."
            ),

            _sectionTitle("Account & Access Control"),
            _bullet(
              "Accounts may be suspended or terminated if violations of these terms are identified."
            ),
            _bullet(
              "Role-based access is enforced to ensure proper system usage."
            ),

            _sectionTitle("Modifications & Updates"),
            _paragraph(
              "Campus Connect reserves the right to update or modify these terms "
              "at any time. Continued use of the platform after changes implies "
              "acceptance of the revised terms.",
            ),

            const SizedBox(height: 24),
            _footerNote(
              "If you have any questions regarding these Terms & Conditions, "
              "please contact the Campus Connect administration.",
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerNote(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Colors.black54,
        ),
      ),
    );
  }
}
