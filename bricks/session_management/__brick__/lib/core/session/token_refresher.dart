import 'token_pair.dart';

/// Abstract interface for token refresh operations
abstract class TokenRefresher {
  /// Attempt to refresh tokens using the refresh token
  /// Returns new TokenPair on success, null on failure
  Future<TokenPair?> refreshTokens(String refreshToken);
}
