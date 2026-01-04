import 'token_pair.dart';

/// Represents the current session state
sealed class SessionState {
  const SessionState();
}

/// No active session (logged out or first launch)
class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// Session is active and valid
class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({required this.tokenPair, this.userId});

  final TokenPair tokenPair;
  final String? userId;
}

/// Session is being refreshed (token expired, attempting refresh)
class SessionRefreshing extends SessionState {
  const SessionRefreshing();
}

/// Session expired and cannot be refreshed (refresh token expired)
class SessionExpired extends SessionState {
  const SessionExpired();
}

/// Session error occurred
class SessionError extends SessionState {
  const SessionError(this.message);
  final String message;
}
