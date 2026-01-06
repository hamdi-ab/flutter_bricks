import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Custom matchers for AsyncValue states
///
/// Usage:
/// ```dart
/// expect(state, isAsyncLoading);
/// expect(state, isAsyncData<User>());
/// expect(state, isAsyncError);
/// ```

/// Matches AsyncLoading state
const Matcher isAsyncLoading = _IsAsyncLoading();

class _IsAsyncLoading extends Matcher {
  const _IsAsyncLoading();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    return item is AsyncLoading;
  }

  @override
  Description describe(Description description) {
    return description.add('is AsyncLoading');
  }
}

/// Matches AsyncData state with optional value matcher
Matcher isAsyncData<T>([Object? valueMatcher]) => _IsAsyncData<T>(valueMatcher);

class _IsAsyncData<T> extends Matcher {
  const _IsAsyncData([this.valueMatcher]);

  final Object? valueMatcher;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! AsyncData<T>) return false;
    if (valueMatcher == null) return true;

    if (valueMatcher is Matcher) {
      return (valueMatcher as Matcher).matches(item.value, matchState);
    }
    return item.value == valueMatcher;
  }

  @override
  Description describe(Description description) {
    final desc = description.add('is AsyncData<$T>');
    if (valueMatcher != null) {
      desc.add(' with value ').addDescriptionOf(valueMatcher);
    }
    return desc;
  }
}

/// Matches AsyncError state with optional error matcher
Matcher isAsyncError([Object? errorMatcher]) => _IsAsyncError(errorMatcher);

class _IsAsyncError extends Matcher {
  const _IsAsyncError([this.errorMatcher]);

  final Object? errorMatcher;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! AsyncError) return false;
    if (errorMatcher == null) return true;

    if (errorMatcher is Matcher) {
      return (errorMatcher as Matcher).matches(item.error, matchState);
    }
    return item.error == errorMatcher;
  }

  @override
  Description describe(Description description) {
    final desc = description.add('is AsyncError');
    if (errorMatcher != null) {
      desc.add(' with error ').addDescriptionOf(errorMatcher);
    }
    return desc;
  }
}
