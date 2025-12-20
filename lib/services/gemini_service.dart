import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiChatService {
  static const String _apiKey = "AIzaSyAdVc_EIieNsGvebG8vm5dWXKBOd9LAoI4";

  final GenerativeModel _model = GenerativeModel(
    // ✅ Gemini 2.0
    model: 'gemini-2.0-flash',
    apiKey: _apiKey,
  );

  Future<String> sendMessage(String message) async {
    try {
      final response = await _model.generateContent([
        Content.text(message),
      ]);

      return response.text ??
          "I couldn't generate a response. Try again.";
    } catch (e) {
      return "AI error occurred. Please try later.";
    }
  }
}
