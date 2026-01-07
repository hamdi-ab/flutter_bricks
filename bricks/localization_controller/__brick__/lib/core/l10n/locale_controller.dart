import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'locale_storage.dart';
import 'locale_storage_impl.dart';

part 'locale_controller.g.dart';

/// Provider for SharedPreferences instance
/// This should be overridden in bootstrap with the actual instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap',
  );
});

/// Provider for LocaleStorage
@riverpod
LocaleStorage localeStorage(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsLocaleStorage(prefs);
}

/// Controller for managing application locale
@riverpod
class LocaleController extends _$LocaleController {
  @override
  FutureOr<AppLocale> build() async {
    final storage = ref.watch(localeStorageProvider);
    final saved = await storage.loadLocale();
    return saved ?? AppLocale.{{default_locale}};
  }

  /// Change the application locale
  Future<void> setLocale(AppLocale locale) async {
    final storage = ref.read(localeStorageProvider);
    state = AsyncData(locale);
    await storage.saveLocale(locale);
  }

  /// Reset to default locale
  Future<void> resetToDefault() async {
    final storage = ref.read(localeStorageProvider);
    await storage.clearLocale();
    state = const AsyncData(AppLocale.{{default_locale}});
  }

  /// Toggle between available locales (useful for quick switching)
  Future<void> toggleLocale() async {
    final current = state.valueOrNull ?? AppLocale.{{default_locale}};
    final values = AppLocale.values;
    final nextIndex = (values.indexOf(current) + 1) % values.length;
    await setLocale(values[nextIndex]);
  }
}
