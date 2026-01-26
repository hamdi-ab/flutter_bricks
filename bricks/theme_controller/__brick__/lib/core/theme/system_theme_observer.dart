{{#include_system_theme}}
/// Interface for observing system theme/brightness changes
abstract class SystemThemeObserver {
  /// Stream of isDark brightness values
  Stream<bool> get onSystemBrightnessChanged;

  /// Get current system isDark status
  bool get isSystemDark;

  /// Dispose resources
  void dispose();
}
{{/include_system_theme}}
