/// Test utilities for Riverpod ViewModels
///
/// This library provides:
/// - [createTestContainer] for creating test ProviderContainers
/// - [TestProviderObserver] for recording state changes
/// - Custom matchers for AsyncValue states
/// - Helper functions for testing notifiers
library viewmodel_test;

export 'test_container.dart';
export 'async_matchers.dart';
export 'notifier_test_helpers.dart';
