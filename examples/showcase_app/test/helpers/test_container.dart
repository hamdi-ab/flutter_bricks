import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a ProviderContainer for testing with optional overrides
///
/// Usage:
/// ```dart
/// final container = createTestContainer(
///   overrides: [
///     userRepositoryProvider.overrideWith((ref) => MockUserRepository()),
///   ],
/// );
/// ```
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    overrides: overrides,
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}

/// Test observer that records all provider state changes
class TestProviderObserver extends ProviderObserver {
  final List<ProviderObserverRecord> records = [];

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    records.add(
      ProviderObserverRecord(
        providerName: provider.name ?? provider.runtimeType.toString(),
        previousValue: previousValue,
        newValue: newValue,
      ),
    );
  }

  /// Clear all recorded events
  void clear() => records.clear();

  /// Get records for a specific provider
  List<ProviderObserverRecord> recordsFor(String providerName) {
    return records.where((r) => r.providerName == providerName).toList();
  }
}

/// Record of a provider state change
class ProviderObserverRecord {
  const ProviderObserverRecord({
    required this.providerName,
    required this.previousValue,
    required this.newValue,
  });

  final String providerName;
  final Object? previousValue;
  final Object? newValue;

  @override
  String toString() => '$providerName: $previousValue -> $newValue';
}
