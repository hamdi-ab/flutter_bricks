# theme_controller Brick

A solid, clean-architecture foundation for managing theme state (Light, Dark, System) in Flutter apps. IT abstracts persistence and system brightness monitoring.

## Features

- **Three Modes**: `light`, `dark`, and `system` (follows OS brightness).
- **Persistent**: Remembers user choice across restarts (using `shared_preferences`).
- **Reactive**: Auto-updates when system theme changes (if in `system` mode).
- **Architecture Agnostic**: Can be used with Riverpod, Bloc, Provider, or ValueNotifier.
- **Testable**: Pure logic with inverted dependencies.

## Generated Files

| File | Description |
|------|-------------|
| `app_theme_mode.dart` | Enum for theme modes. |
| `theme_state.dart` | Immutable state holding mode and effective brightness. |
| `theme_storage.dart` | Abstraction for persistence. |
| `theme_storage_impl.dart` | Concrete implementation using `shared_preferences`. |
| `system_theme_observer.dart` | Abstraction for OS brightness changes. |
| `system_theme_observer_impl.dart` | Wrapper around `WidgetsBindingObserver`. |
| `theme_controller.dart` | The brain that connects storage, system, and state. |

## Dependencies

Add `shared_preferences` to your `pubspec.yaml`:
```yaml
dependencies:
  shared_preferences: ^2.2.0
```

## Usage Example (Riverpod)

```dart
// 1. Storage Provider
final themeStorageProvider = Provider<ThemeStorage>((ref) {
  return ThemeStorageImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider), // Assume this exists
  );
});

// 2. Controller Provider
final themeControllerProvider = Provider<ThemeController>((ref) {
  return ThemeController(
    storage: ref.watch(themeStorageProvider),
    systemObserver: SystemThemeObserverImpl(),
  );
});

// 3. State Provider (consumes controller stream)
final themeStateProvider = StreamProvider<ThemeState>((ref) {
  final controller = ref.watch(themeControllerProvider);
  
  // Initialize on start
  ref.onDispose(controller.dispose);
  controller.load(); // Fire and forget load
  
  return controller.state;
});

// 4. Usage in UI
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    
    return MaterialApp(
      themeMode: themeState.value?.mode == AppThemeMode.light 
          ? ThemeMode.light 
          : themeState.value?.mode == AppThemeMode.dark 
              ? ThemeMode.dark 
              : ThemeMode.system,
      // ...
    );
  }
}
```
