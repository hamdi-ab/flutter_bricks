# theme_controller Brick

A solid, clean-architecture foundation for managing theme state in Flutter apps. It abstracts persistence and system brightness monitoring.

## Features

- **Flexible Modes**: Choose between Light/Dark only or Light/Dark/System.
- **Persistent**: Remembers user choice across restarts (using `shared_preferences`).
- **Reactive**: Auto-updates when system theme changes (if in `system` mode).
- **Architecture Agnostic**: Can be used with Riverpod, Bloc, Provider, or ValueNotifier.
- **Testable**: Pure logic with inverted dependencies.

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `include_system_theme` | boolean | `true` | Include system theme option. `true` = Light/Dark/System, `false` = Light/Dark toggle only. |
| `default_mode` | string | `system` | Default theme mode (`system`, `light`, `dark`). |

## Generated Files

| File | Description | Conditional |
|------|-------------|-------------|
| `app_theme_mode.dart` | Enum for theme modes. | - |
| `theme_state.dart` | Immutable state holding mode and effective brightness. | - |
| `theme_storage.dart` | Abstraction for persistence. | - |
| `theme_storage_impl.dart` | Concrete implementation using `shared_preferences`. | - |
| `system_theme_observer.dart` | Abstraction for OS brightness changes. | Only when `include_system_theme=true` |
| `system_theme_observer_impl.dart` | Wrapper around `WidgetsBindingObserver`. | Only when `include_system_theme=true` |
| `theme_controller.dart` | The brain that connects storage, system, and state. | - |

## Dependencies

Add `shared_preferences` to your `pubspec.yaml`:
```yaml
dependencies:
  shared_preferences: ^2.2.0
```

## Usage Example

### With System Theme (`include_system_theme: true`)

```dart
// Controller with system observer
final themeController = ThemeController(
  storage: ThemeStorageImpl(sharedPreferences: prefs),
  systemObserver: SystemThemeObserverImpl(),
);

// Set specific mode
await themeController.setMode(AppThemeMode.system);
await themeController.setMode(AppThemeMode.dark);
```

### Without System Theme (`include_system_theme: false`)

```dart
// Controller without system observer
final themeController = ThemeController(
  storage: ThemeStorageImpl(sharedPreferences: prefs),
);

// Simple toggle between light and dark
themeController.toggle();

// Or set specific mode
await themeController.setMode(AppThemeMode.light);
```

### UI Integration (Riverpod)

```dart
// State Provider
final themeStateProvider = StreamProvider<ThemeState>((ref) {
  final controller = ref.watch(themeControllerProvider);
  ref.onDispose(controller.dispose);
  controller.load();
  return controller.state;
});

// Simple Toggle Switch (when include_system_theme is false)
Switch(
  value: themeState.isDark,
  onChanged: (_) => themeController.toggle(),
)

// Three-way selector (when include_system_theme is true)
SegmentedButton<AppThemeMode>(
  segments: [
    ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
    ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
    ButtonSegment(value: AppThemeMode.system, label: Text('System')),
  ],
  selected: {themeState.mode},
  onSelectionChanged: (modes) => themeController.setMode(modes.first),
)
```
