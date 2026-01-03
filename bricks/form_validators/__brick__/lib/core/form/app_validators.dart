import 'validation_result.dart';

/// Type definition for a validator function
typedef Validator<T> = ValidationResult Function(T? value);

/// Collection of common validators
class AppValidators {
  const AppValidators._();

  /// Validates that the value is not null or empty
  static Validator<String> required({
    String message = 'This field is required',
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return ValidationFailure(message);
      }
      return const ValidationSuccess();
    };
  }

  /// Validates email format
  static Validator<String> email({String message = 'Invalid email address'}) {
    return (value) {
      if (value == null || value.isEmpty)
        return const ValidationSuccess(); // Optional field

      final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      );

      if (!emailRegex.hasMatch(value)) {
        return ValidationFailure(message);
      }
      return const ValidationSuccess();
    };
  }

  /// Validates minimum length
  static Validator<String> minLength(int min, {String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return const ValidationSuccess();
      if (value.length < min) {
        return ValidationFailure(message ?? 'Must be at least $min characters');
      }
      return const ValidationSuccess();
    };
  }

  /// Compose multiple validators
  static Validator<T> compose<T>(List<Validator<T>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result is ValidationFailure) {
          return result;
        }
      }
      return const ValidationSuccess();
    };
  }
}
