import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_mode.dart';
import 'theme_storage.dart';

/// Implementation of [ThemeStorage] using [SharedPreferences]
class ThemeStorageImpl implements ThemeStorage {
  ThemeStorageImpl({required SharedPreferences sharedPreferences})
    : _prefs = sharedPreferences;

  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  @override
  Future<AppThemeMode?> loadThemeMode() async {
    final storedValue = _prefs.getString(_key);
    if (storedValue == null) return null;

    try {
      return AppThemeMode.values.firstWhere((e) => e.name == storedValue);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_key, mode.name);
  }
}
