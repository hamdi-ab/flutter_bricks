# viewmodel_test Brick

Test utilities for Riverpod ViewModels including container helpers, state observers, custom matchers, and notifier test scaffolding.

## Generated Files

| File | Description |
|------|-------------|
| `test_container.dart` | `createTestContainer()` + `TestProviderObserver` |
| `async_matchers.dart` | Custom matchers for `AsyncValue` states |
| `notifier_test_helpers.dart` | `testNotifier()`, `expectStateSequence()` |
| `test_helpers.dart` | Barrel export |

## Dependencies

Add to `dev_dependencies` in `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  mocktail: ^1.0.0
```

## Usage Examples

### 1. Basic Container Setup

```dart
import 'package:your_app/test/helpers/test_helpers.dart';

void main() {
  test('user loads successfully', () async {
    final container = createTestContainer(
      overrides: [
        userRepositoryProvider.overrideWith((ref) => MockUserRepository()),
      ],
    );

    await container.read(userNotifierProvider.future);
    
    expect(container.read(userNotifierProvider), isAsyncData<User>());
  });
}
```

### 2. Using Custom Matchers

```dart
// Check loading state
expect(state, isAsyncLoading);

// Check data state
expect(state, isAsyncData<User>());
expect(state, isAsyncData<User>(predicate((u) => u.name == 'John')));

// Check error state
expect(state, isAsyncError);
expect(state, isAsyncError(isA<AuthException>()));
```

### 3. Using testNotifier Helper

```dart
testNotifier<AuthNotifier, User?>(
  'login updates state to success',
  provider: authNotifierProvider,
  overrides: [
    authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
  ],
  act: (notifier) => notifier.login('test@test.com', 'password'),
  expect: (state) => expect(state, isAsyncData<User?>()),
);
```

### 4. Testing State Sequences

```dart
test('login goes through loading then success', () async {
  final container = createTestContainer(
    overrides: [
      authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
    ],
  );

  await expectStateSequence<AuthNotifier, User?>(
    container: container,
    provider: authNotifierProvider,
    act: (notifier) => notifier.login('test@test.com', 'password'),
    states: [
      isAsyncLoading,
      isAsyncData<User?>(),
    ],
  );
});
```

### 5. Using TestProviderObserver

```dart
test('records all state changes', () async {
  final observer = TestProviderObserver();
  final container = createTestContainer(observers: [observer]);

  await container.read(userNotifierProvider.notifier).loadUser();

  final records = observer.recordsFor('userNotifierProvider');
  expect(records.length, 2); // loading, then data
});
```

## Example Mock

```dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

// In test setup:
when(() => mockRepo.login(any(), any())).thenAnswer(
  (_) async => Success(User(id: '1', name: 'Test')),
);
```
