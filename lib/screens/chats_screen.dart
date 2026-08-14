import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/avatar_utils.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final currentUserId = context.read<AuthProvider>().currentUser!.id;
      context.read<ChatProvider>().loadChats(currentUserId);
      _initialized = true;
    }
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (isToday) {
      return DateFormat.jm().format(dateTime); // e.g. 2:30 PM
    }

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;

    if (isYesterday) return 'Yesterday';

    return DateFormat.yMd().format(dateTime);
  }

  Future<void> _openChat(ChatModel chat, String currentUserId) async {
    final otherUserId = chat.otherParticipantId(currentUserId);
    final otherUser = await context.read<UserProvider>().getUserById(
          otherUserId,
        );
    if (otherUser == null || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId: chat.id,
          otherUser: otherUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().currentUser!.id;
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.chats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Head to Users to start chatting with someone.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: chatProvider.chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    return _ChatCard(
                      chat: chat,
                      timeLabel: _formatTimestamp(chat.lastMessageAt),
                      onTap: () => _openChat(chat, currentUserId),
                    );
                  },
                ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final ChatModel chat;
  final String timeLabel;
  final VoidCallback onTap;

  const _ChatCard({
    required this.chat,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = chat.otherUserName.isEmpty ? 'Unknown user' : chat.otherUserName;
    final preview = chat.lastMessage.isEmpty ? 'Say hello!' : chat.lastMessage;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              GradientAvatar(name: chat.otherUserName, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
