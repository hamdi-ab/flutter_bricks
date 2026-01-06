import 'ui_state.dart';

// Note: This extension assumes you've generated the failure_model brick.
// If not, you can delete this file or replace AppException with a generic error type.
// import '../../errors/app_exception.dart';
// import '../../errors/result.dart';

/*
extension ResultToUiState<T> on Result<T> {
  /// Convert a Result<T> to a UiState<T>
  UiState<T> toUiState({
    bool Function(T data)? isEmpty,
    String? emptyMessage,
  }) {
    return when(
      success: (data) {
        if (isEmpty?.call(data) ?? false) {
          return UiState.empty(emptyMessage);
        }
        return UiState.success(data);
      },
      failure: (error) => UiState.error(error.message, error),
    );
  }
}
*/

/// Generic extensions on Future<T>
extension FutureToUiState<T> on Future<T> {
  /// Convert a Future directly to UiState
  ///
  /// Usage:
  /// ```dart
  /// state = UiState.loading();
  /// state = await repository.getData().toUiState();
  /// ```
  Future<UiState<T>> toUiState() async {
    try {
      final result = await this;
      return UiState.success(result);
    } catch (e) {
      return UiState.error(e.toString(), e);
    }
  }
}
