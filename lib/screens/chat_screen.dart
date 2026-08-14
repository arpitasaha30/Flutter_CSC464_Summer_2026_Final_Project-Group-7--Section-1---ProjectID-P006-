import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/app_theme.dart';
import '../utils/avatar_utils.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback so context.read is safe here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().listenToMessages(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop listening to this room's messages when leaving the screen.
    context.read<MessageProvider>().clear();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    final currentUserId = context.read<AuthProvider>().currentUser!.id;
    await context.read<MessageProvider>().sendMessage(
          chatRoomId: widget.chatRoomId,
          senderId: currentUserId,
          receiverId: widget.otherUser.id,
          text: text,
        );

    _messageController.clear();

    // Scroll to the latest message after the list rebuilds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().currentUser!.id;
    final messageProvider = context.watch<MessageProvider>();

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            GradientAvatar(name: widget.otherUser.name, radius: 18, fontSize: 13),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherUser.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messageProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👋', style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'Say hello to ${widget.otherUser.name}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount: messageProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = messageProvider.messages[index];
                          final isMe = message.senderId == currentUserId;
                          return _MessageBubble(
                            text: message.message,
                            isMe: isMe,
                            timestamp: message.timestamp,
                          );
                        },
                      ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp != null ? DateFormat.jm().format(timestamp!) : '',
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.75) : Colors.grey.shade500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    filled: false,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
