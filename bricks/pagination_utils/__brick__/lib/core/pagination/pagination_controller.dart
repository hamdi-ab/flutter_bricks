import 'dart:async';
import 'paged_result.dart';
import 'pagination_state.dart';

/// Callback to fetch a specific page
typedef FetchPageCallback<T> = Future<PagedResult<T>> Function(int pageKey);

/// Framework-agnostic controller for pagination logic.
/// Can be used with Riverpod, Bloc, or Provider.
class PaginationController<T> {
  PaginationController({
    required this.fetchPage,
    this.startPageKey = 0,
    this.pageSize = {
      {page_size},
    },
  }) {
    // Initial state
    _stateController.add(const PaginationInitial());
  }

  final FetchPageCallback<T> fetchPage;
  final int startPageKey;
  final int pageSize;

  final _stateController = StreamController<PaginationState<T>>.broadcast();
  PaginationState<T> _currentState = const PaginationInitial();

  /// Stream of state changes
  Stream<PaginationState<T>> get state => _stateController.stream;

  /// Current synchronous state
  PaginationState<T> get currentState => _currentState;

  /// Load the first page
  Future<void> loadFirstPage() async {
    // Deduplicate: Don't load if already loading
    if (_currentState is PaginationLoadingFirst) return;

    _updateState(const PaginationLoadingFirst());

    try {
      final result = await fetchPage(startPageKey);

      _updateState(
        PaginationLoaded(
          items: result.items,
          totalItems: result.totalItems,
          nextPageKey: result.nextPageKey,
        ),
      );
    } catch (e) {
      _updateState(PaginationError(e.toString()));
    }
  }

  /// Load the next page
  Future<void> loadNextPage() async {
    // Guard: Must be loaded to load *next*
    if (_currentState is! PaginationLoaded<T>) return;

    final currentLoaded = _currentState as PaginationLoaded<T>;

    // Guard: Reached max?
    if (currentLoaded.hasReachedMax) return;

    // Guard: Already loading next? (Prevent double triggers)
    if (_currentState is PaginationLoadingNext) return;

    // Transition to LoadingNext (Keep old data visible)
    _updateState(
      PaginationLoadingNext(
        items: currentLoaded.items,
        totalItems: currentLoaded.totalItems,
        nextPageKey: currentLoaded.nextPageKey,
      ),
    );

    try {
      final nextPageKey = currentLoaded.nextPageKey!;
      final result = await fetchPage(nextPageKey);

      // Append new items to existing list
      final newItems = [...currentLoaded.items, ...result.items];

      _updateState(
        PaginationLoaded(
          items: newItems,
          totalItems: result.totalItems,
          nextPageKey: result.nextPageKey,
        ),
      );
    } catch (e) {
      // Transition to ErrorNext (Keep old data visible + error message)
      _updateState(
        PaginationErrorNext(
          items: currentLoaded.items,
          totalItems: currentLoaded.totalItems,
          nextPageKey: currentLoaded.nextPageKey,
          message: e.toString(),
        ),
      );
    }
  }

  /// Refresh the list (alias for loadFirstPage logic)
  Future<void> refresh() => loadFirstPage();

  void _updateState(PaginationState<T> newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _stateController.close();
  }
}
