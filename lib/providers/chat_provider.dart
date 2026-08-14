import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../utils/chat_room_utils.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ChatModel> _chats = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;

  /// Listens to the current user's chat list in real time, ordered by the
  /// most recent message. Also resolves the other participant's name for
  /// display in the chat list.
  void loadChats(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final loadedChats = snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
          .toList();

      // Resolve the other participant's display name for each chat.
      for (final chat in loadedChats) {
        final otherId = chat.otherParticipantId(currentUserId);
        if (otherId.isNotEmpty) {
          final userDoc =
              await _firestore.collection('users').doc(otherId).get();
          if (userDoc.exists) {
            chat.otherUserName =
                UserModel.fromMap(userDoc.id, userDoc.data()!).name;
          }
        }
      }

      _chats = loadedChats;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Finds the existing chat room between two users, or creates a new one.
  /// The room id is deterministic, so the same two users always resolve
  /// to the same room regardless of who initiates it.
  Future<String> getOrCreateChatRoom({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final chatRoomId =
        ChatRoomUtils.generateChatRoomId(currentUserId, otherUserId);

    final docRef = _firestore.collection('chats').doc(chatRoomId);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
