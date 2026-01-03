# form_validators Brick

A collection of pure Dart, reusable validators and type-safe validation result models.

## Features

- **ValidationResult**: Sealed class for proper pattern matching in UI.
- **Composition**: Easily combine multiple validators (`required` + `email`).
- **Testable**: Pure functions, no Flutter context needed.

## Generated Files

| File | Description |
|------|-------------|
| `validation_result.dart` | `ValidationSuccess` or `ValidationFailure`. |
| `app_validators.dart` | Setup for common rules (email, required, minLength). |

## Usage Example

```dart
// 1. Define Validations
final emailValidator = AppValidators.compose([
  AppValidators.required(),
  AppValidators.email(),
]);

// 2. Use in ViewModel
void validateEmail(String input) {
  final result = emailValidator(input);
  
  switch (result) {
    case ValidationSuccess():
       // proceed
       break;
    case ValidationFailure(message: final msg):
       // state = state.copyWith(emailError: msg);
       break; 
  }
}

// 3. Use in Flutter Form
TextFormField(
  validator: (value) {
    final result = emailValidator(value);
    return switch (result) {
      ValidationSuccess() => null, // Flutter expects null for success
      ValidationFailure(message: final msg) => msg,
    };
  },
)
```
