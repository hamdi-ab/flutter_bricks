import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'locale_storage.dart';

/// SharedPreferences implementation of LocaleStorage
class SharedPrefsLocaleStorage implements LocaleStorage {
  SharedPrefsLocaleStorage(this._prefs);

  static const String _key = 'app_locale';
  final SharedPreferences _prefs;

  @override
  Future<AppLocale?> loadLocale() async {
    final code = _prefs.getString(_key);
    if (code == null) return null;
    return AppLocale.fromCode(code);
  }

  @override
  Future<void> saveLocale(AppLocale locale) async {
    await _prefs.setString(_key, locale.code);
  }

  @override
  Future<void> clearLocale() async {
    await _prefs.remove(_key);
  }
}
