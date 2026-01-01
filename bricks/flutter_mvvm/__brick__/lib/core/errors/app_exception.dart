/// Base exception class for application errors
sealed class AppException implements Exception {
  const AppException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network error occurred',
    super.statusCode,
  ]);
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred',
    super.statusCode,
  ]);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException([
    super.message = 'Authentication failed',
    super.statusCode,
  ]);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Validation failed',
    super.statusCode,
  ]);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException([super.message = 'An unknown error occurred']);
}
