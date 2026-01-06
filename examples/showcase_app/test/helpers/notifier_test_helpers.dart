import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_container.dart';

/// Helper for testing AsyncNotifier-based ViewModels
///
/// Usage:
/// ```dart
/// testAsyncNotifier<User?>(
///   'login success updates state',
///   provider: authNotifierProvider,
///   overrides: [
///     authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
///   ],
///   act: (container) async {
///     await container.read(authNotifierProvider.notifier).login('test@test.com', 'password');
///   },
///   expect: (state) => expect(state, isAsyncData<User?>()),
/// );
/// ```
void testAsyncNotifier<T>(
  String description, {
  required AsyncNotifierProvider<AsyncNotifier<T>, T> provider,
  List<Override> overrides = const [],
  Future<void> Function(ProviderContainer container)? act,
  void Function(AsyncValue<T> state)? expect,
  void Function(ProviderContainer container)? verify,
}) {
  test(description, () async {
    final container = createTestContainer(overrides: overrides);

    // Wait for initial build
    await container.read(provider.future);

    // Act
    if (act != null) {
      await act(container);
    }

    // Expect
    if (expect != null) {
      expect(container.read(provider));
    }

    // Verify
    verify?.call(container);
  });
}

/// Helper for testing Notifier-based ViewModels (non-async)
void testSyncNotifier<T>(
  String description, {
  required NotifierProvider<Notifier<T>, T> provider,
  List<Override> overrides = const [],
  void Function(ProviderContainer container)? act,
  void Function(T state)? expect,
  void Function(ProviderContainer container)? verify,
}) {
  test(description, () {
    final container = createTestContainer(overrides: overrides);

    // Act
    if (act != null) {
      act(container);
    }

    // Expect
    if (expect != null) {
      expect(container.read(provider));
    }

    // Verify
    verify?.call(container);
  });
}

/// Helper for state sequence testing
///
/// Verifies that a notifier goes through expected state transitions
///
/// Usage:
/// ```dart
/// await expectStateSequence<User?>(
///   container: container,
///   provider: authNotifierProvider,
///   act: (container) => container.read(authNotifierProvider.notifier).login('test@test.com', 'password'),
///   states: [
///     isAsyncLoading,
///     isAsyncData<User?>(),
///   ],
/// );
/// ```
Future<void> expectStateSequence<T>({
  required ProviderContainer container,
  required AsyncNotifierProvider<AsyncNotifier<T>, T> provider,
  required Future<void> Function(ProviderContainer container) act,
  required List<Matcher> states,
}) async {
  final stateChanges = <AsyncValue<T>>[];

  container.listen<AsyncValue<T>>(
    provider,
    (previous, next) => stateChanges.add(next),
    fireImmediately: false,
  );

  await act(container);

  // Allow async updates to complete
  await Future<void>.delayed(Duration.zero);

  expect(
    stateChanges.length,
    states.length,
    reason:
        'Expected ${states.length} state changes, got ${stateChanges.length}: $stateChanges',
  );

  for (var i = 0; i < states.length; i++) {
    expect(stateChanges[i], states[i], reason: 'State at index $i');
  }
}
