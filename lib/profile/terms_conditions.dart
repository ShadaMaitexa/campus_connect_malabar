import 'package:flutter/material.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "1. This system is for academic use only.\n"
          "2. Data misuse is prohibited.\n"
          "3. Admin reserves monitoring rights.\n"
          "4. Marketplace usage is voluntary.",
        ),
      ),
    );
  }
}
