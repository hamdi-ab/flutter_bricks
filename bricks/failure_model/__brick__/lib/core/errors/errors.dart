/// Unified error model for consistent exception handling
///
/// This library provides:
/// - A sealed `AppException` class hierarchy for domain errors
/// - A `Result<T>` type for functional error handling
/// - An `ExceptionMapper` for exception-to-error conversion
library errors;

export 'app_exception.dart';
export 'result.dart';
export 'exception_mapper.dart';
