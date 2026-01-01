import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
{{#use_firebase}}
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
{{/use_firebase}}

import 'config/providers/app_providers.dart';
import 'core/utils/logger.dart';

/// Bootstrap the application with async initialization
Future<ProviderContainer> bootstrap() async {
  // Setup error handling
  FlutterError.onError = (details) {
    logger.error('Flutter Error', error: details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Platform Error', error: error, stackTrace: stack);
    return true;
  };

  {{#use_firebase}}
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  {{/use_firebase}}

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create provider container with overrides
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  logger.info('App bootstrapped successfully');

  return container;
}
