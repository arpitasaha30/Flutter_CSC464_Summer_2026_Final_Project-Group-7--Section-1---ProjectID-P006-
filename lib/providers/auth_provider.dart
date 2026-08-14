import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/password_utils.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _sessionKey = 'currentUserId';

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _sessionChecked = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get sessionChecked => _sessionChecked;

  /// Called once at app startup to restore a saved session.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_sessionKey);
    if (savedId != null) {
      final doc = await _firestore.collection('users').doc(savedId).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.id, doc.data()!);
      } else {
        await prefs.remove(_sessionKey);
      }
    }
    _sessionChecked = true;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final existing = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _errorMessage = 'An account with this email already exists.';
        _setLoading(false);
        return false;
      }

      final docRef = _firestore.collection('users').doc();
      final hashedPassword = PasswordUtils.hash(password);

      await docRef.set({
        'name': name.trim(),
        'email': normalizedEmail,
        'password': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = UserModel(
        id: docRef.id,
        name: name.trim(),
        email: normalizedEmail,
        createdAt: DateTime.now(),
      );

      await _saveSession(docRef.id);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _errorMessage = 'No account found with this email.';
        _setLoading(false);
        return false;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final storedHash = data['password'] as String? ?? '';

      if (!PasswordUtils.verify(password, storedHash)) {
        _errorMessage = 'Incorrect password.';
        _setLoading(false);
        return false;
      }

      _currentUser = UserModel.fromMap(doc.id, data);
      await _saveSession(doc.id);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
