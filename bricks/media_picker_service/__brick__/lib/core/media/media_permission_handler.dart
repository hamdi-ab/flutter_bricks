/// Abstract handler for requesting media permissions
abstract class MediaPermissionHandler {
  /// Request permission to access the camera
  Future<bool> requestCameraPermission();

  /// Request permission to access photo gallery/storage
  Future<bool> requestGalleryPermission();

  /// Request permission to access files (general storage)
  Future<bool> requestStoragePermission();

  /// Check if camera permission is permanently denied
  Future<bool> isCameraPermanentlyDenied();

  /// Check if gallery permission is permanently denied
  Future<bool> isGalleryPermanentlyDenied();
}
