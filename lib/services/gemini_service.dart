import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiChatService {
  final String _apiKey = dotenv.get('GROQ_API_KEY', fallback: '');
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      return "Groq API Key is missing. Please check your .env file.";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': message}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "I couldn't generate a response.";
      } else {
        return "AI error occurred (${response.statusCode}). Please try later.";
      }
    } catch (e) {
      return "Error connecting to AI service. Please try later.";
    }
  }
}
