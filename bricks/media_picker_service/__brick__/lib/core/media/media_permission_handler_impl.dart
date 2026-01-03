import 'package:permission_handler/permission_handler.dart';
import 'media_permission_handler.dart';

/// Concrete implementation using [permission_handler] package
class MediaPermissionHandlerImpl implements MediaPermissionHandler {
  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestGalleryPermission() async {
    // Basic gallery permission strategy
    // Note: Android 13+ should use Permission.photos
    // This is a simplified implementation for the boilerplate
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    return await Permission.storage.request().isGranted;
  }

  @override
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Future<bool> isCameraPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied;
  }

  @override
  Future<bool> isGalleryPermanentlyDenied() async {
    // Check both potential permissions
    return await Permission.photos.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied;
  }
}
