# failure_model Brick

Unified error modeling with `AppException` hierarchy, `Result<T>` type, and exception mapping — **fully aligned with the `flutter_mvvm` vocabulary**.

## Why This Matters

Without unified error handling:
- Each layer invents its own exceptions
- Error messages are inconsistent
- Retry logic is fragmented

This brick provides a **drop-in upgrade** for the existing error files in `flutter_mvvm`.

## Generated Files

| File | Description |
|------|-------------|
| `app_exception.dart` | Sealed `AppException` class hierarchy |
| `result.dart` | `Result<T>` type with `when()`, `map()`, `flatMap()` |
| `exception_mapper.dart` | Exception-to-AppException conversion + `guard()` |
| `errors.dart` | Barrel export |

## Exception Types

| Type | Use Case |
|------|----------|
| `NetworkException` | API calls, connectivity issues |
| `AuthException` | Login, session, authorization |
| `CacheException` | Local storage, Hive, SharedPrefs |
| `ValidationException` | Form validation, input errors |
| `PermissionException` | Camera, location, notifications |
| `UnknownException` | Unexpected errors |

## Usage Examples

### 1. Repository with guard()

```dart
Future<Result<User>> getUser(String id) {
  return ExceptionMapper.guard(() async {
    final response = await apiClient.get('/users/$id');
    return User.fromJson(response.data);
  });
}
```

### 2. ViewModel handling

```dart
final result = await userRepository.getUser(id);

result.when(
  success: (user) => state = UserLoaded(user),
  failure: (error) => state = UserError(error.message),
);
```

### 3. Pattern matching on exception type

```dart
void handleError(AppException error) {
  switch (error) {
    case NetworkException(isRecoverable: true):
      showRetryDialog();
    case AuthException():
      navigateToLogin();
    case ValidationException(fieldErrors: final errors):
      showFieldErrors(errors);
    case _:
      showGenericError(error.message);
  }
}
```

### 4. Chaining Results

```dart
final result = await userRepository.getUser(id)
  .map((user) => user.profile)
  .flatMap((profile) => profileRepository.getDetails(profile.id));
```

## Alignment with flutter_mvvm

This brick uses the **exact same naming** as the existing `flutter_mvvm` error files:

| flutter_mvvm | failure_model (Enhanced) |
|--------------|-------------------------|
| `AppException` | `AppException` ✅ |
| `NetworkException` | `NetworkException` ✅ |
| `AuthException` | `AuthException` ✅ |
| `CacheException` | `CacheException` ✅ |
| `ValidationException` | `ValidationException` ✅ |
| `Result<T>` | `Result<T>` ✅ |
| `Success` / `Failure` | `Success` / `Failure` ✅ |

**New features added:**
- `code` field for programmatic handling
- `isRecoverable` flag for retry logic
- `originalException` for debugging
- `ExceptionMapper.guard()` for cleaner try-catch
- `map()`, `flatMap()`, `getOrElse()` helpers
