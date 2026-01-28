import 'dart:async';

import 'session_state.dart';
import 'token_pair.dart';
import 'token_refresher.dart';
import 'token_storage.dart';

/// Controller for managing authentication sessions
///
/// Handles:
/// - Token persistence and retrieval
{{#enable_auto_refresh}}
/// - Automatic token refresh before expiry
{{/enable_auto_refresh}}
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
{{#enable_auto_refresh}}
  Timer? _refreshTimer;

  /// Buffer time before expiry to trigger refresh
  static const _refreshBuffer = Duration(minutes: {{refresh_buffer_minutes}});
{{/enable_auto_refresh}}

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
{{#enable_auto_refresh}}
      _scheduleTokenRefresh(storedTokens);
{{/enable_auto_refresh}}
    }
  }

  /// Set new session after login/registration
  Future<void> setSession(TokenPair tokenPair) async {
    await _tokenStorage.saveTokens(tokenPair);
    _updateState(SessionAuthenticated(tokenPair: tokenPair));
{{#enable_auto_refresh}}
    _scheduleTokenRefresh(tokenPair);
{{/enable_auto_refresh}}
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
{{#enable_auto_refresh}}
    _cancelRefreshTimer();
{{/enable_auto_refresh}}
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

  /// Manually refresh the current session
  Future<bool> refreshSession() async {
    final state = _currentState;
    if (state is! SessionAuthenticated) return false;
    return _refreshSession(state.tokenPair);
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
{{#enable_auto_refresh}}
      _scheduleTokenRefresh(newTokens);
{{/enable_auto_refresh}}
      return true;
    } catch (e) {
      _updateState(SessionError(e.toString()));
      return false;
    }
  }
{{#enable_auto_refresh}}

  /// Schedule automatic token refresh before expiry
  void _scheduleTokenRefresh(TokenPair tokenPair) {
    _cancelRefreshTimer();

    // Calculate time until refresh needed
    final expiresIn = tokenPair.accessTokenExpiresAt.difference(DateTime.now());
    final refreshIn = expiresIn - _refreshBuffer;

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
{{/enable_auto_refresh}}

  void _updateState(SessionState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
{{#enable_auto_refresh}}
    _cancelRefreshTimer();
{{/enable_auto_refresh}}
    _stateController.close();
  }
}
