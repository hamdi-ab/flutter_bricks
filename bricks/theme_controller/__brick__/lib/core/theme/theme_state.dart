import 'app_theme_mode.dart';

/// Represents the current state of the application theme
class ThemeState {
  const ThemeState({required this.mode, required this.brightness});

  /// The selected theme mode (user preference)
  final AppThemeMode mode;

  /// The effective brightness (calculated from mode + system)
  /// Using String 'light' or 'dark' to avoid Flutter imports in core model
  final String brightness;

  bool get isDark => brightness == 'dark';
  bool get isLight => brightness == 'light';

  ThemeState copyWith({AppThemeMode? mode, String? brightness}) {
    return ThemeState(
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
    );
  }
}
