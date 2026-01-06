import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/providers/app_providers.dart';
import '../model/user.dart';
import '../service/auth_repository.dart';
import '../service/auth_repository_impl.dart';

part 'auth_notifier.g.dart';

/// Auth repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}

/// Auth state notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // Load current user on init
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    return result.dataOrNull;
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await ref
        .read(authRepositoryProvider)
        .login(email, password);

    state = result.when(
      success: (user) => AsyncData(user),
      failure: (error) => AsyncError(error, StackTrace.current),
    );
  }

  /// Register new user
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncLoading();

    final result = await ref
        .read(authRepositoryProvider)
        .register(email, password, displayName);

    state = result.when(
      success: (user) => AsyncData(user),
      failure: (error) => AsyncError(error, StackTrace.current),
    );
  }

  /// Logout current user
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
