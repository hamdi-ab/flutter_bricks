import 'package:flutter/material.dart';

import 'app_locale.dart';

// Import generated localizations (created by flutter gen-l10n)
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extension on BuildContext for convenient localization access
extension L10nExtension on BuildContext {
  /// Get the generated AppLocalizations instance
  /// Uncomment after running `flutter gen-l10n`
  // AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Get the current locale
  Locale get currentLocale => Localizations.localeOf(this);

  /// Get the current language code
  String get languageCode => currentLocale.languageCode;

  /// Check if current locale uses RTL text direction
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Get the current AppLocale enum value
  AppLocale get appLocale => AppLocale.fromCode(languageCode);
}

/// Extension on AppLocale for convenient access
extension AppLocaleExtension on AppLocale {
  /// Get the text direction for this locale
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
}
