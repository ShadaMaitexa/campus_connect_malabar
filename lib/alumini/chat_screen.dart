import 'package:campus_connect_malabar/theme/app_theme.dart';
import 'package:campus_connect_malabar/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // receiver
  final String name;

  const ChatScreen({super.key, required this.userId, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late final String chatId;

  @override
  void initState() {
    super.initState();
    chatId = _getChatId(currentUserId, widget.userId);
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // create/update chat
    await chatRef.set({
      'users': [currentUserId, widget.userId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // add message
    await chatRef.collection('messages').add({
      'senderId': currentUserId,
      'receiverId': widget.userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: CustomAppBar(
        title: widget.name,
        showBackButton: true,
        gradient: AppGradients.primary,
        leading: Hero(
          tag: 'avatar_${widget.userId}',
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// 🔹 MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("Connecting..."));
                }

                var messages = snapshot.data!.docs;

                // Sort messages client-side by timestamp (descending)
                messages.sort((a, b) {
                  final timestampA =
                      (a['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  final timestampB =
                      (b['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  return timestampB.compareTo(timestampA);
                });

                if (messages.isEmpty) {
                  return _buildEmptyChat(isDark);
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUserId;

                    return _buildMessageBubble(msg['text'], isMe, isDark);
                  },
                );
              },
            ),
          ),

          /// 🔹 INPUT BAR
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Start the conversation",
            style: GoogleFonts.poppins(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Say hello to ${widget.name}!",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe ? AppGradients.primary : null,
          color: isMe
              ? null
              : (isDark ? AppTheme.darkSurfaceSecondary : Colors.grey.shade200),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isMe
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceSecondary
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(26),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
