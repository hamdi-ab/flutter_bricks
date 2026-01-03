import 'app_theme_mode.dart';

/// Interface for persisting theme preference
abstract class ThemeStorage {
  /// Load persisted theme mode
  Future<AppThemeMode?> loadThemeMode();

  /// Save theme mode
  Future<void> saveThemeMode(AppThemeMode mode);
}
