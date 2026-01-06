/// Base class for all application exceptions
///
/// This provides a unified exception model that can be used across
/// all layers of the application (network, auth, cache, validation, etc.)
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalException,
    this.stackTrace,
    this.isRecoverable = true,
  });

  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  /// HTTP status code if applicable
  final int? statusCode;

  /// The original exception that caused this (if any)
  final Object? originalException;

  /// Stack trace for debugging
  final StackTrace? stackTrace;

  /// Whether the error is recoverable (can retry)
  final bool isRecoverable;

  @override
  String toString() => 'AppException($code): $message';
}

/// Network-related exceptions (API calls, connectivity)
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.statusCode,
    super.originalException,
    super.stackTrace,
    super.isRecoverable = true,
  });

  /// Factory for timeout errors
  factory NetworkException.timeout() => const NetworkException(
    message: 'Request timed out. Please check your connection.',
    code: 'TIMEOUT',
  );

  /// Factory for noConnection
  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection.',
    code: 'NO_CONNECTION',
  );

  /// Factory for server errors (5xx)
  factory NetworkException.serverError([int? statusCode]) => NetworkException(
    message: 'Server error occurred. Please try again later.',
    code: 'SERVER_ERROR',
    statusCode: statusCode,
  );

  /// Factory for client errors (4xx)
  factory NetworkException.clientError(String message, [int? statusCode]) =>
      NetworkException(
        message: message,
        code: 'CLIENT_ERROR',
        statusCode: statusCode,
        isRecoverable: false,
      );
}

/// Authentication and authorization exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.statusCode,
    super.originalException,
    super.stackTrace,
    super.isRecoverable = false,
  });

  /// Factory for invalid credentials
  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid email or password.',
    code: 'INVALID_CREDENTIALS',
  );

  /// Factory for session expired
  factory AuthException.sessionExpired() => const AuthException(
    message: 'Your session has expired. Please log in again.',
    code: 'SESSION_EXPIRED',
  );

  /// Factory for unauthorized access
  factory AuthException.unauthorized() => const AuthException(
    message: 'You are not authorized to perform this action.',
    code: 'UNAUTHORIZED',
  );

  /// Factory for account locked
  factory AuthException.accountLocked() => const AuthException(
    message: 'Your account has been locked. Please contact support.',
    code: 'ACCOUNT_LOCKED',
  );
}

/// Cache and local storage exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
    super.isRecoverable = true,
  });

  /// Factory for read error
  factory CacheException.readError() => const CacheException(
    message: 'Failed to read from cache.',
    code: 'CACHE_READ_ERROR',
  );

  /// Factory for write error
  factory CacheException.writeError() => const CacheException(
    message: 'Failed to write to cache.',
    code: 'CACHE_WRITE_ERROR',
  );

  /// Factory for cache miss
  factory CacheException.notFound() => const CacheException(
    message: 'Data not found in cache.',
    code: 'CACHE_NOT_FOUND',
  );
}

/// Input validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
    super.isRecoverable = false,
    this.field,
    this.fieldErrors = const {},
  });

  /// The field that failed validation (if single field)
  final String? field;

  /// Map of field names to error messages (for form validation)
  final Map<String, String> fieldErrors;

  /// Factory for required field
  factory ValidationException.required(String field) => ValidationException(
    message: '$field is required.',
    code: 'REQUIRED',
    field: field,
  );

  /// Factory for invalid format
  factory ValidationException.invalidFormat(String field) =>
      ValidationException(
        message: '$field has an invalid format.',
        code: 'INVALID_FORMAT',
        field: field,
      );

  /// Factory for multiple field errors
  factory ValidationException.multiple(Map<String, String> errors) =>
      ValidationException(
        message: 'Validation failed for ${errors.length} field(s).',
        code: 'MULTIPLE_ERRORS',
        fieldErrors: errors,
      );
}

/// Permission and access exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
    super.isRecoverable = true,
  });

  /// Factory for denied permission
  factory PermissionException.denied(String permission) => PermissionException(
    message: '$permission permission was denied.',
    code: 'PERMISSION_DENIED',
  );

  /// Factory for permanently denied permission
  factory PermissionException.permanentlyDenied(
    String permission,
  ) => PermissionException(
    message:
        '$permission permission is permanently denied. Please enable it in settings.',
    code: 'PERMISSION_PERMANENTLY_DENIED',
    isRecoverable: false,
  );
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN',
    super.originalException,
    super.stackTrace,
    super.isRecoverable = false,
  });
}
