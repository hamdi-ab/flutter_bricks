import 'package:dio/dio.dart';

import 'session_controller.dart';

/// Dio interceptor that automatically injects auth tokens
/// and handles 401 responses by triggering session expiration
class SessionInterceptor extends Interceptor {
  SessionInterceptor(this._sessionController);

  final SessionController _sessionController;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get a valid access token (will auto-refresh if needed)
    final token = await _sessionController.getValidAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - clear session
    if (err.response?.statusCode == 401) {
      _sessionController.clearSession();
    }

    super.onError(err, handler);
  }
}
