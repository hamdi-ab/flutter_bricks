/// Standardized UI state wrapper for consistent view logic
///
/// This sealed class hierarchy defines the 5 canonical states for any UI:
/// 1. [UiState.idle] - Initial state, no action taken yet
/// 2. [UiState.loading] - Operation in progress
/// 3. [UiState.success] - Operation completed successfully with data
/// 4. [UiState.empty] - Operation completed successfully but returned no data
/// 5. [UiState.error] - Operation failed
sealed class UiState<T> {
  const UiState();

  /// Initial state
  const factory UiState.idle() = UiStateIdle<T>;

  /// Loading state
  const factory UiState.loading([String? message]) = UiStateLoading<T>;

  /// Success state with data
  const factory UiState.success(T data) = UiStateSuccess<T>;

  /// Empty state (no data found)
  const factory UiState.empty([String? message]) = UiStateEmpty<T>;

  /// Error state with message
  const factory UiState.error(String message, [Object? error]) =
      UiStateError<T>;

  /// Pattern matching helper
  R when<R>({
    required R Function() idle,
    required R Function(String? message) loading,
    required R Function(T data) success,
    required R Function(String? message) empty,
    required R Function(String message, Object? error) error,
  }) {
    return switch (this) {
      UiStateIdle() => idle(),
      UiStateLoading(message: final msg) => loading(msg),
      UiStateSuccess(data: final d) => success(d),
      UiStateEmpty(message: final msg) => empty(msg),
      UiStateError(message: final msg, error: final err) => error(msg, err),
    };
  }

  /// Maybe pattern matching helper
  R maybeWhen<R>({
    required R Function() orElse,
    R Function()? idle,
    R Function(String? message)? loading,
    R Function(T data)? success,
    R Function(String? message)? empty,
    R Function(String message, Object? error)? error,
  }) {
    return switch (this) {
      UiStateIdle() => idle?.call() ?? orElse(),
      UiStateLoading(message: final msg) => loading?.call(msg) ?? orElse(),
      UiStateSuccess(data: final d) => success?.call(d) ?? orElse(),
      UiStateEmpty(message: final msg) => empty?.call(msg) ?? orElse(),
      UiStateError(message: final msg, error: final err) =>
        error?.call(msg, err) ?? orElse(),
    };
  }

  // --- Convenience Getters ---

  bool get isIdle => this is UiStateIdle<T>;
  bool get isLoading => this is UiStateLoading<T>;
  bool get isSuccess => this is UiStateSuccess<T>;
  bool get isEmpty => this is UiStateEmpty<T>;
  bool get isError => this is UiStateError<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
    UiStateSuccess(data: final d) => d,
    _ => null,
  };

  /// Get error message if error, null otherwise
  String? get errorOrNull => switch (this) {
    UiStateError(message: final msg) => msg,
    _ => null,
  };
}

// --- Implementation Classes ---

class UiStateIdle<T> extends UiState<T> {
  const UiStateIdle();
}

class UiStateLoading<T> extends UiState<T> {
  const UiStateLoading([this.message]);
  final String? message;
}

class UiStateSuccess<T> extends UiState<T> {
  const UiStateSuccess(this.data);
  final T data;
}

class UiStateEmpty<T> extends UiState<T> {
  const UiStateEmpty([this.message]);
  final String? message;
}

class UiStateError<T> extends UiState<T> {
  const UiStateError(this.message, [this.error]);
  final String message;
  final Object? error;
}
