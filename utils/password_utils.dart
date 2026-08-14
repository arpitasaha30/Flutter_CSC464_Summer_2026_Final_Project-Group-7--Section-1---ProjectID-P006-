import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes a password with SHA-256 before it is ever written to Firestore.
/// This project stores data in Firestore only (no Firebase Auth), so we
/// must never persist plain-text credentials.
class PasswordUtils {
  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String password, String hashedPassword) {
    return hash(password) == hashedPassword;
  }
}
