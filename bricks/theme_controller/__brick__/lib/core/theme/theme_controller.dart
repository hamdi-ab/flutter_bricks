import 'dart:async';

import 'app_theme_mode.dart';
{{#include_system_theme}}
import 'system_theme_observer.dart';
{{/include_system_theme}}
import 'theme_state.dart';
import 'theme_storage.dart';

/// Controller that manages theme state, persistence, and system changes
class ThemeController {
  ThemeController({
    required ThemeStorage storage,
{{#include_system_theme}}
    required SystemThemeObserver systemObserver,
{{/include_system_theme}}
  })  : _storage = storage{{#include_system_theme}},
        _systemObserver = systemObserver{{/include_system_theme}};

  final ThemeStorage _storage;
{{#include_system_theme}}
  final SystemThemeObserver _systemObserver;
{{/include_system_theme}}

  final _stateController = StreamController<ThemeState>.broadcast();
  late ThemeState _currentState;
{{#include_system_theme}}
  StreamSubscription<bool>? _systemSubscription;
{{/include_system_theme}}

  /// Existing state stream
  Stream<ThemeState> get state => _stateController.stream;

  /// Current state value
  ThemeState get currentState => _currentState;

  /// Initialize controller: load persisting theme and set up listeners
  Future<void> load() async {
    // 1. Load persisted mode or default to {{default_mode}}
    final persistedMode = await _storage.loadThemeMode();
    final initialMode = persistedMode ?? AppThemeMode.{{default_mode}};

    // 2. Initialize state
    _currentState = _calculateState(initialMode);
    _stateController.add(_currentState);
{{#include_system_theme}}

    // 3. Listen to system changes if needed
    _updateSystemListener(initialMode);
{{/include_system_theme}}
  }

  /// Switch to a specific theme mode
  Future<void> setMode(AppThemeMode mode) async {
    if (_currentState.mode == mode) return;

    // 1. Update state
    _currentState = _calculateState(mode);
    _stateController.add(_currentState);

    // 2. Persist
    await _storage.saveThemeMode(mode);
{{#include_system_theme}}

    // 3. Update listener
    _updateSystemListener(mode);
{{/include_system_theme}}
  }

  /// Toggle between light and dark theme
  void toggle() {
    final newMode = _currentState.isDark ? AppThemeMode.light : AppThemeMode.dark;
    setMode(newMode);
  }

  /// Calculate effective state based on mode and system brightness
  ThemeState _calculateState(AppThemeMode mode) {
    String brightness;
    switch (mode) {
      case AppThemeMode.light:
        brightness = 'light';
      case AppThemeMode.dark:
        brightness = 'dark';
{{#include_system_theme}}
      case AppThemeMode.system:
        brightness = _systemObserver.isSystemDark ? 'dark' : 'light';
{{/include_system_theme}}
    }
    return ThemeState(mode: mode, brightness: brightness);
  }
{{#include_system_theme}}

  /// Manage system brightness listener
  void _updateSystemListener(AppThemeMode mode) {
    if (mode == AppThemeMode.system) {
      if (_systemSubscription == null) {
        _systemSubscription = _systemObserver.onSystemBrightnessChanged.listen(
          (isDark) {
             // System changed, so re-calculate state with current mode (system)
             // but new brightness
             _currentState = _calculateState(AppThemeMode.system);
             _stateController.add(_currentState);
          },
        );
      }
    } else {
      _systemSubscription?.cancel();
      _systemSubscription = null;
    }
  }
{{/include_system_theme}}

  /// Dispose resources
  void dispose() {
    _stateController.close();
{{#include_system_theme}}
    _systemSubscription?.cancel();
    _systemObserver.dispose();
{{/include_system_theme}}
  }
}
