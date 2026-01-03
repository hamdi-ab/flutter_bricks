import 'paged_result.dart';

/// Represents the state of a paginated list
sealed class PaginationState<T> {
  const PaginationState();
}

/// Initial state, no data loaded yet
class PaginationInitial<T> extends PaginationState<T> {
  const PaginationInitial();
}

/// Loading the very first page
class PaginationLoadingFirst<T> extends PaginationState<T> {
  const PaginationLoadingFirst();
}

/// Data loaded (and potentially ready to load more)
class PaginationLoaded<T> extends PaginationState<T> {
  const PaginationLoaded({
    required this.items,
    required this.totalItems,
    this.nextPageKey,
  });

  final List<T> items;
  final int totalItems;
  final int? nextPageKey;

  bool get hasReachedMax => nextPageKey == null;
}

/// Loading a subsequent page (appending)
class PaginationLoadingNext<T> extends PaginationLoaded<T> {
  const PaginationLoadingNext({
    required super.items,
    required super.totalItems,
    super.nextPageKey,
  });
}

/// Error occurred
class PaginationError<T> extends PaginationState<T> {
  const PaginationError(this.message);
  final String message;
}

/// Error occurred while loading next page (data is still visible)
class PaginationErrorNext<T> extends PaginationLoaded<T> {
  const PaginationErrorNext({
    required super.items,
    required super.totalItems,
    super.nextPageKey,
    required this.message,
  });

  final String message;
}
