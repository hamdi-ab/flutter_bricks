import 'dart:async';

import 'session_state.dart';
import 'token_pair.dart';
import 'token_refresher.dart';
import 'token_storage.dart';

/// Controller for managing authentication sessions
///
/// Handles:
/// - Token persistence and retrieval
/// - Automatic token refresh before expiry
/// - Session state broadcasting
/// - Logout and session clearing
class SessionController {
  SessionController({
    required TokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
  }) : _tokenStorage = tokenStorage,
       _tokenRefresher = tokenRefresher;

  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;

  final _stateController = StreamController<SessionState>.broadcast();
  SessionState _currentState = const SessionUnauthenticated();
  Timer? _refreshTimer;

  /// Stream of session state changes
  Stream<SessionState> get sessionState => _stateController.stream;

  /// Current synchronous session state
  SessionState get currentState => _currentState;

  /// Initialize session from stored tokens
  Future<void> initialize() async {
    final storedTokens = await _tokenStorage.loadTokens();

    if (storedTokens == null) {
      _updateState(const SessionUnauthenticated());
      return;
    }

    // Check if refresh token is expired
    if (storedTokens.isRefreshTokenExpired) {
      await _tokenStorage.clearTokens();
      _updateState(const SessionExpired());
      return;
    }

    // Check if access token needs refresh
    if (storedTokens.isAccessTokenExpired) {
      await _refreshSession(storedTokens);
    } else {
      _updateState(SessionAuthenticated(tokenPair: storedTokens));
      _scheduleTokenRefresh(storedTokens);
    }
  }

  /// Set new session after login/registration
  Future<void> setSession(TokenPair tokenPair) async {
    await _tokenStorage.saveTokens(tokenPair);
    _updateState(SessionAuthenticated(tokenPair: tokenPair));
    _scheduleTokenRefresh(tokenPair);
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    _cancelRefreshTimer();
    await _tokenStorage.clearTokens();
    _updateState(const SessionUnauthenticated());
  }

  /// Get current access token if valid
  Future<String?> getValidAccessToken() async {
    final state = _currentState;
    if (state is! SessionAuthenticated) return null;

    final tokenPair = state.tokenPair;

    // If access token is expired, try to refresh
    if (tokenPair.isAccessTokenExpired) {
      if (!tokenPair.canRefresh) {
        await clearSession();
        _updateState(const SessionExpired());
        return null;
      }

      final refreshed = await _refreshSession(tokenPair);
      if (!refreshed) return null;

      // Get new token after refresh
      final newState = _currentState;
      if (newState is SessionAuthenticated) {
        return newState.tokenPair.accessToken;
      }
      return null;
    }

    return tokenPair.accessToken;
  }

  /// Refresh the current session
  Future<bool> _refreshSession(TokenPair currentTokens) async {
    _updateState(const SessionRefreshing());

    try {
      final newTokens = await _tokenRefresher.refreshTokens(
        currentTokens.refreshToken,
      );

      if (newTokens == null) {
        await _tokenStorage.clearTokens();
        _updateState(const SessionExpired());
        return false;
      }

      await _tokenStorage.saveTokens(newTokens);
      _updateState(SessionAuthenticated(tokenPair: newTokens));
      _scheduleTokenRefresh(newTokens);
      return true;
    } catch (e) {
      _updateState(SessionError(e.toString()));
      return false;
    }
  }

  /// Schedule automatic token refresh before expiry
  void _scheduleTokenRefresh(TokenPair tokenPair) {
    _cancelRefreshTimer();

    // Calculate time until refresh needed (refresh 1 minute before expiry)
    final refreshBuffer = const Duration(minutes: 1);
    final expiresIn = tokenPair.accessTokenExpiresAt.difference(DateTime.now());
    final refreshIn = expiresIn - refreshBuffer;

    // Don't schedule if already expired or very short time
    if (refreshIn.isNegative || refreshIn.inSeconds < 10) return;

    _refreshTimer = Timer(refreshIn, () {
      _refreshSession(tokenPair);
    });
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _updateState(SessionState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _cancelRefreshTimer();
    _stateController.close();
  }
}
