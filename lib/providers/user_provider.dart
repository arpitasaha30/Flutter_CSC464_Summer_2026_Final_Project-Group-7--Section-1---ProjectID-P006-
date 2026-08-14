import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  /// Listens to all registered users in real time, excluding the current user.
  void loadUsers(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
