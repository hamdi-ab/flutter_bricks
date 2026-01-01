import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/api_client.dart';
import '../env/env_config.dart';
import '../router/app_router.dart';

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in bootstrap');
});

/// Environment provider
final envProvider = Provider<EnvConfig>((ref) {
  // Change this to ProdEnv() for production
  return DevEnv();
});

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final env = ref.watch(envProvider);
  return ApiClient(baseUrl: env.apiBaseUrl);
});
