import 'app_locale.dart';

/// Abstract interface for locale persistence
abstract class LocaleStorage {
  /// Load the saved locale from storage
  /// Returns null if no locale was previously saved
  Future<AppLocale?> loadLocale();

  /// Save the selected locale to storage
  Future<void> saveLocale(AppLocale locale);

  /// Clear the saved locale (revert to default)
  Future<void> clearLocale();
}
