import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../network/api_client.dart';
import '../env/env_config.dart';

/// Shared Preferences (for non-sensitive data)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in bootstrap');
});

/// Secure Storage (for sensitive data like tokens)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Environment provider
final envProvider = Provider<EnvConfig>((ref) {
  // Change this to ProdEnv() for production
  return DevEnv();
});

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final env = ref.watch(envProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(baseUrl: env.apiBaseUrl, secureStorage: secureStorage);
});
