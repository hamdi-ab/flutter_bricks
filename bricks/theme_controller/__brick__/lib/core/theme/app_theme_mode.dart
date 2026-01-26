/// Available theme modes for the application
enum AppThemeMode {
  /// Always use light theme
  light,

  /// Always use dark theme
  dark,
{{#include_system_theme}}

  /// Follow system brightness setting
  system,
{{/include_system_theme}}
}
