# pagination_utils Brick

A generic, framework-agnostic foundation for infinite scrolling lists and pagination. Logic is decoupled from UI.

## Features

- **Generic**: Works with any data type `T`.
- **State Managed**: Explicit states (`Initial`, `LoadingFirst`, `Loaded`, `LoadingNext`, `Error`).
- **Robust Logic**: Handles deduplication, appending data, and error preserveration during paging.
- **Framework Agnostic**: Pure Dart logic. Compatible with Riverpod, Bloc, Provider, etc.

## Generated Files

| File | Description |
|------|-------------|
| `paged_result.dart` | Model wrapping list + metadata. |
| `pagination_state.dart` | Sealed class for UI state. |
| `pagination_controller.dart` | Logic for fetching next pages and appending data. |

## Usage Example (Riverpod)

1. **Define a Provider**:
```dart
final feedPaginationProvider = Provider.autoDispose<PaginationController<Post>>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  
  final controller = PaginationController<Post>(
    fetchPage: (pageKey) => repo.fetchPosts(page: pageKey),
  );
  
  // Load initial data immediately
  controller.loadFirstPage();
  ref.onDispose(controller.dispose);
  
  return controller;
});

// Stream provider for easy UI consumption
final feedStateProvider = StreamProvider.autoDispose<PaginationState<Post>>((ref) {
  return ref.watch(feedPaginationProvider).state;
});
```

2. **Consume in UI**:
```dart
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(feedStateProvider);
    
    return stateAsync.when(
      data: (state) => switch (state) {
        PaginationLoadingFirst() => CircularProgressIndicator(),
        PaginationLoaded(items: final items) => ListView.builder(
          itemCount: items.length + (state.hasReachedMax ? 0 : 1), // +1 for loader
          itemBuilder: (context, index) {
            if (index >= items.length) {
              // Trigger next page when scrolling to bottom
              ref.read(feedPaginationProvider).loadNextPage();
              return CircularProgressIndicator();
            }
            return PostItem(items[index]);
          },
        ),
        PaginationError(message: final msg) => Text('Error: $msg'),
        _ => SizedBox.shrink(),
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('System Error'),
    );
  }
}
```
