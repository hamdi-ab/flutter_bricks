import 'dart:io';

/// Unified result type for media and file picking operations
sealed class MediaPickResult {
  const MediaPickResult();
}

/// Operation successful with selected files
class MediaPickSuccess extends MediaPickResult {
  const MediaPickSuccess(this.files);
  final List<File> files;
}

/// User cancelled the operation
class MediaPickCancelled extends MediaPickResult {
  const MediaPickCancelled();
}

/// Permission was denied by user
class MediaPickPermissionDenied extends MediaPickResult {
  const MediaPickPermissionDenied();
}

/// Permission is permanently denied (requires app settings)
class MediaPickPermissionPermanentlyDenied extends MediaPickResult {
  const MediaPickPermissionPermanentlyDenied();
}

/// An unexpected error occurred
class MediaPickError extends MediaPickResult {
  const MediaPickError(this.message);
  final String message;
}
