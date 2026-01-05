# ui_state Brick

Standardized UI state wrapper defining the 5 canonical states of any view: **Idle, Loading, Success, Empty, and Error**.

## Why This Matters

Instead of boolean flags (`isLoading`, `hasError`) or nullable data (`data?`), this brick enforces a rigid state machine. This prevents impossible states (like "loading but also error") and ensures the UI handles every scenario.

## Generated Files

| File | Description |
|------|-------------|
| `ui_state.dart` | Sealed `UiState<T>` class hierarchy |
| `ui_state_extensions.dart` | Helper extensions |
| `state.dart` | Barrel export |

## The 5 States

| State | Class | Meaning |
|-------|-------|---------|
| **Idle** | `UiStateIdle` | Initial state, nothing happened yet |
| **Loading** | `UiStateLoading` | Operation in progress (spinner) |
| **Success** | `UiStateSuccess` | Data is ready to show |
| **Empty** | `UiStateEmpty` | Success, but no data to show (placeholder) |
| **Error** | `UiStateError` | Operation failed (retry button) |

## Usage Examples

### 1. In ViewModel (Riverpod)

```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UiState<User> build() => const UiState.idle();

  Future<void> loadUser() async {
    state = const UiState.loading();
    
    // Using failure_model generic Result
    final result = await ref.read(userRepoProvider).getUser();
    
    state = result.when(
      success: (user) => UiState.success(user),
      failure: (error) => UiState.error(error.message, error),
    );
  }
}
```

### 2. In Widget (Pattern Matching)

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(userNotifierProvider);

  return state.when(
    idle: () => const Text('Ready to load'),
    loading: (_) => const CircularProgressIndicator(),
    success: (user) => UserProfile(user: user),
    empty: (msg) => EmptyStateWidget(message: msg),
    error: (msg, _) => ErrorRetryWidget(
      message: msg,
      onRetry: () => ref.read(userNotifierProvider.notifier).loadUser(),
    ),
  );
}
```

### 3. Maybe When (Partial Matching)

```dart
// Only handle success, show loading for everything else
return state.maybeWhen(
  success: (data) => ShowData(data),
  orElse: () => const LinearProgressIndicator(),
);
```

### 4. Integration with failure_model

If you are using the `failure_model` brick, you can uncomment the powerful extension in `ui_state_extensions.dart` to convert `Result<T>` directly to `UiState<T>`.

```dart
// ui_state_extensions.dart
extension ResultToUiState<T> on Result<T> {
  UiState<T> toUiState() => when(
    success: (data) => UiState.success(data),
    failure: (e) => UiState.error(e.message, e),
  );
}

// ViewModel usage
state = (await repo.getData()).toUiState();
```
