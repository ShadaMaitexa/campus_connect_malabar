import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _emailJsUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  static Future<void> sendMentorApprovalEmail({
    required String mentorName,
    required String mentorEmail,
  }) async {
    final response = await http.post(
      Uri.parse(_emailJsUrl),
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'service_kzcfqpu',
        'template_id': 'template_gw3t7xn',
        'user_id': 'dIGm53WkqVsUlfDrm',
        'template_params': {
          'mentor_name': mentorName,
          'mentor_email': mentorEmail,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('EmailJS Error: ${response.body}');
    }
  }
}
