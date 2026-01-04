# session_management Brick

Enterprise-grade session management with token pairs, automatic refresh, and session state streaming.

## Features

- **Token Pairs**: Manage access + refresh tokens with expiry tracking
- **Auto-Refresh**: Automatically refresh tokens before expiry
- **Session State Stream**: React to session changes (login, logout, expiry)
- **Secure Storage**: Uses `flutter_secure_storage` for token persistence
- **Dio Integration**: Interceptor for automatic token injection

## Generated Files

| File | Description |
|------|-------------|
| `token_pair.dart` | Model for access/refresh token pair with expiry |
| `session_state.dart` | Sealed class for session lifecycle states |
| `token_storage.dart` | Abstract storage interface |
| `token_storage_impl.dart` | Secure storage implementation |
| `token_refresher.dart` | Abstract refresh interface |
| `session_controller.dart` | Main controller with auto-refresh logic |
| `session_interceptor.dart` | Dio interceptor for token injection |

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0
```

## Usage Example

### 1. Implement TokenRefresher

```dart
class ApiTokenRefresher implements TokenRefresher {
  ApiTokenRefresher(this._dio);
  final Dio _dio;

  @override
  Future<TokenPair?> refreshTokens(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      return TokenPair(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
        accessTokenExpiresAt: DateTime.parse(response.data['expiresAt']),
      );
    } catch (_) {
      return null;
    }
  }
}
```

### 2. Setup SessionController

```dart
final sessionController = SessionController(
  tokenStorage: TokenStorageImpl(),
  tokenRefresher: ApiTokenRefresher(dio),
);

// Initialize from stored tokens
await sessionController.initialize();
```

### 3. Listen to Session State

```dart
sessionController.sessionState.listen((state) {
  switch (state) {
    case SessionAuthenticated():
      // Navigate to home
      break;
    case SessionUnauthenticated():
    case SessionExpired():
      // Navigate to login
      break;
    case SessionRefreshing():
      // Show loading indicator
      break;
    case SessionError(message: final msg):
      // Show error
      break;
  }
});
```

### 4. Use with Dio

```dart
dio.interceptors.add(SessionInterceptor(sessionController));
```

### 5. Login/Logout

```dart
// After successful login
await sessionController.setSession(TokenPair(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
  accessTokenExpiresAt: response.expiresAt,
));

// Logout
await sessionController.clearSession();
```
