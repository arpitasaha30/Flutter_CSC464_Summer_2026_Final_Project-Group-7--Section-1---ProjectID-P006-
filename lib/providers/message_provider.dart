import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/message_model.dart';

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;
  String? _activeChatRoomId;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Listens for real-time updates to a chat room's messages, ordered
  /// oldest to newest.
  void listenToMessages(String chatRoomId) {
    if (_activeChatRoomId == chatRoomId && _subscription != null) return;

    _activeChatRoomId = chatRoomId;
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatRoomId);

    final message = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: trimmed,
    );

    await chatRef.collection('messages').add(message.toMap());

    await chatRef.update({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _activeChatRoomId = null;
    _messages = [];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
