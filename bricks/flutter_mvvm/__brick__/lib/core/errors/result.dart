import 'app_exception.dart';

/// Result type for handling success and failure cases
sealed class Result<T> {
  const Result();

  /// Execute different callbacks based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(error: final error) => failure(error),
    };
  }

  /// Execute callback only on success
  R? whenSuccess<R>(R Function(T data) callback) {
    return switch (this) {
      Success(data: final data) => callback(data),
      Failure() => null,
    };
  }

  /// Execute callback only on failure
  R? whenFailure<R>(R Function(AppException error) callback) {
    return switch (this) {
      Success() => null,
      Failure(error: final error) => callback(error),
    };
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };

  /// Get error if failure, null otherwise
  AppException? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };
}

/// Success result
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failure result
class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
