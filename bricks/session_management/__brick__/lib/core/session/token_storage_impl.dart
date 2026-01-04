import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_pair.dart';
import 'token_storage.dart';

/// Secure token storage implementation using flutter_secure_storage
class TokenStorageImpl implements TokenStorage {
  TokenStorageImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'session_token_pair';

  @override
  Future<void> saveTokens(TokenPair tokenPair) async {
    final json = jsonEncode(tokenPair.toJson());
    await _storage.write(key: _tokenKey, value: json);
  }

  @override
  Future<TokenPair?> loadTokens() async {
    final json = await _storage.read(key: _tokenKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return TokenPair.fromJson(map);
    } catch (_) {
      // Corrupted data, clear it
      await clearTokens();
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
  }
}
