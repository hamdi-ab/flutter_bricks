import 'token_pair.dart';

/// Abstract interface for secure token storage
abstract class TokenStorage {
  /// Save token pair securely
  Future<void> saveTokens(TokenPair tokenPair);

  /// Load stored token pair (returns null if none)
  Future<TokenPair?> loadTokens();

  /// Clear all stored tokens
  Future<void> clearTokens();
}
