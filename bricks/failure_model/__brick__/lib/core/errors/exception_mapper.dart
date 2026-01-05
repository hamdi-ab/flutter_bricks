import 'dart:async';
import 'dart:io';

import 'app_exception.dart';
import 'result.dart';

/// Maps exceptions to domain AppExceptions
///
/// This centralizes exception-to-error conversion,
/// ensuring consistent error handling across the app.
class ExceptionMapper {
  const ExceptionMapper._();

  /// Map any exception to an AppException
  static AppException fromException(
    Object exception, [
    StackTrace? stackTrace,
  ]) {
    // Already an AppException
    if (exception is AppException) {
      return exception;
    }

    if (exception is SocketException) {
      return NetworkException.noConnection();
    }

    if (exception is HttpException) {
      return NetworkException(
        message: exception.message,
        code: 'HTTP_ERROR',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    if (exception is FormatException) {
      return ValidationException(
        message: exception.message,
        code: 'FORMAT_ERROR',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    if (exception is TimeoutException) {
      return NetworkException.timeout();
    }

    // Default to unknown
    return UnknownException(
      message: exception.toString(),
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Map HTTP status codes to AppExceptions
  static AppException fromStatusCode(int statusCode, [String? message]) {
    if (statusCode >= 500) {
      return NetworkException.serverError(statusCode);
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Bad request.',
          code: 'BAD_REQUEST',
        );
      case 401:
        return AuthException.invalidCredentials();
      case 403:
        return AuthException.unauthorized();
      case 404:
        return NetworkException.clientError(
          message ?? 'Resource not found.',
          statusCode,
        );
      case 408:
        return NetworkException.timeout();
      case 429:
        return NetworkException(
          message: 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
          isRecoverable: true,
        );
      default:
        return NetworkException.clientError(
          message ?? 'Request failed.',
          statusCode,
        );
    }
  }

  /// Try to execute a function and return a Result
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(fromException(e, stackTrace));
    }
  }

  /// Synchronous version of guard
  static Result<T> guardSync<T>(T Function() action) {
    try {
      final result = action();
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(fromException(e, stackTrace));
    }
  }
}
