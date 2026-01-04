/// Represents a pair of authentication tokens
class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  /// Check if access token is expired (with buffer for network latency)
  bool get isAccessTokenExpired {
    final buffer = Duration(seconds: 30);
    return DateTime.now().isAfter(accessTokenExpiresAt.subtract(buffer));
  }

  /// Check if refresh token is expired
  bool get isRefreshTokenExpired {
    if (refreshTokenExpiresAt == null) return false;
    return DateTime.now().isAfter(refreshTokenExpiresAt!);
  }

  /// Check if session can be refreshed
  bool get canRefresh => !isRefreshTokenExpired;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
    'refreshTokenExpiresAt': refreshTokenExpiresAt?.toIso8601String(),
  };

  /// Create from JSON
  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.parse(json['refreshTokenExpiresAt'] as String)
          : null,
    );
  }
}
