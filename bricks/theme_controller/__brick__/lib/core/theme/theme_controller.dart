import 'dart:async';

import 'app_theme_mode.dart';
import 'system_theme_observer.dart';
import 'theme_state.dart';
import 'theme_storage.dart';

/// Controller that manages theme state, persistence, and system changes
class ThemeController {
  ThemeController({
    required ThemeStorage storage,
    required SystemThemeObserver systemObserver,
  })  : _storage = storage,
        _systemObserver = systemObserver;

  final ThemeStorage _storage;
  final SystemThemeObserver _systemObserver;

  final _stateController = StreamController<ThemeState>.broadcast();
  late ThemeState _currentState;
  StreamSubscription<bool>? _systemSubscription;

  /// Existing state stream
  Stream<ThemeState> get state => _stateController.stream;

  /// Current state value
  ThemeState get currentState => _currentState;

  /// Initialize controller: load persisting theme and set up listeners
  Future<void> load() async {
    // 1. Load persisted mode or default to system
    final persistedMode = await _storage.loadThemeMode();
    final initialMode = persistedMode ?? AppThemeMode.{{default_mode}};

    // 2. Initialize state
    _currentState = _calculateState(initialMode);
    _stateController.add(_currentState);

    // 3. Listen to system changes if needed
    _updateSystemListener(initialMode);
  }

  /// Switch to a specific theme mode
  Future<void> setMode(AppThemeMode mode) async {
    if (_currentState.mode == mode) return;

    // 1. Update state
    _currentState = _calculateState(mode);
    _stateController.add(_currentState);

    // 2. Persist
    await _storage.saveThemeMode(mode);

    // 3. Update listener
    _updateSystemListener(mode);
  }

  /// Calculate effective state based on mode and system brightness
  ThemeState _calculateState(AppThemeMode mode) {
    String brightness;
    switch (mode) {
      case AppThemeMode.light:
        brightness = 'light';
      case AppThemeMode.dark:
        brightness = 'dark';
      case AppThemeMode.system:
        brightness = _systemObserver.isSystemDark ? 'dark' : 'light';
    }
    return ThemeState(mode: mode, brightness: brightness);
  }

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

  /// Dispose resources
  void dispose() {
    _stateController.close();
    _systemSubscription?.cancel();
    _systemObserver.dispose();
  }
}
