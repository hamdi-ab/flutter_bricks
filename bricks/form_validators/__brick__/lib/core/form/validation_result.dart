/// Represents the outcome of running a validator on a value
sealed class ValidationResult {
  const ValidationResult();
}

/// Validation passed
class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

/// Validation failed with a generic message
class ValidationFailure extends ValidationResult {
  const ValidationFailure(this.message);
  final String message;
}
