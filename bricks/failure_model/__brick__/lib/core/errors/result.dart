import 'app_exception.dart';

/// A Result type that represents either a success or a failure
///
/// This provides a functional approach to error handling,
/// avoiding exceptions for control flow.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Failure<T>;

  /// Get the value or null if failure
  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => null,
  };

  /// Get the error or null if success
  AppException? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final e) => e,
  };

  /// Execute different callbacks based on result type (matches existing API)
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) => switch (this) {
    Success<T>(data: final d) => success(d),
    Failure<T>(error: final e) => failure(e),
  };

  /// Map the success value to a new type
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(data: final d) => Success(transform(d)),
    Failure<T>(error: final e) => Failure(e),
  };

  /// FlatMap for chaining Result operations
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => switch (this) {
    Success<T>(data: final d) => transform(d),
    Failure<T>(error: final e) => Failure(e),
  };

  /// Map the error to a different error
  Result<T> mapError(AppException Function(AppException error) transform) =>
      switch (this) {
        Success<T>() => this,
        Failure<T>(error: final e) => Failure(transform(e)),
      };

  /// Get data or throw the error
  T get dataOrThrow => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>(error: final e) => throw e,
  };

  /// Get data or return a default
  T getOrElse(T Function() defaultValue) => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => defaultValue(),
  };

  /// Execute side effect on success
  Result<T> onSuccess(void Function(T data) action) {
    if (this case Success<T>(data: final d)) {
      action(d);
    }
    return this;
  }

  /// Execute side effect on failure
  Result<T> onFailure(void Function(AppException error) action) {
    if (this case Failure<T>(error: final e)) {
      action(e);
    }
    return this;
  }
}

/// Success result
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  String toString() => 'Success($data)';
}

/// Failure result
class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;

  @override
  String toString() => 'Failure(${error.code}: ${error.message})';
}

/// Extension to create Results easily
extension ResultExtensions<T> on T {
  /// Wrap a value in a Success
  Result<T> get asSuccess => Success(this);
}

extension AppExceptionExtensions on AppException {
  /// Wrap an error in a Failure result
  Result<T> asFailure<T>() => Failure<T>(this);
}
