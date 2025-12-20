import 'package:campus_connect_malabar/services/gemini_service.dart';
import 'package:flutter/material.dart';


class StudyChatbotScreen extends StatefulWidget {
  const StudyChatbotScreen({super.key});

  @override
  State<StudyChatbotScreen> createState() => _StudyChatbotScreenState();
}

class _StudyChatbotScreenState extends State<StudyChatbotScreen> {
  final GeminiChatService _chatService = GeminiChatService();
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": text});
      _loading = true;
    });

    final reply = await _chatService.sendMessage(
      "You are an academic assistant for college students. "
      "Explain clearly, exam-oriented and simple.\n\nQuestion: $text",
    );

    setState(() {
      _messages.add({"role": "ai", "text": reply});
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Assistant"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          /// CHAT AREA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    elevation: 2,
                    color: isUser
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: CircularProgressIndicator(),
            ),

          /// INPUT BAR (MATCHING UI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black12.withOpacity(0.08),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask about notes, syllabus, exams...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF6366F1),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
