import 'package:flutter/material.dart';

/// Supported application locales
enum AppLocale {
  /// English
  en(Locale('en')),

  /// Arabic (RTL)
  ar(Locale('ar'));

  const AppLocale(this.locale);

  /// The Flutter Locale instance
  final Locale locale;

  /// Get the language code (e.g., 'en', 'ar')
  String get code => locale.languageCode;

  /// Get display name for the locale
  String get displayName {
    switch (this) {
      case AppLocale.en:
        return 'English';
      case AppLocale.ar:
        return 'العربية';
    }
  }

  /// Whether this locale uses RTL text direction
  bool get isRtl => this == AppLocale.ar;

  /// Get AppLocale from language code
  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLocale.{{default_locale}},
    );
  }

  /// Get all supported Locale instances
  static List<Locale> get supportedLocales =>
      AppLocale.values.map((e) => e.locale).toList();
}
