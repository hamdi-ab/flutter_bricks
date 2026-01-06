import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'media_permission_handler.dart';
import 'media_pick_result.dart';
import 'media_picker_service.dart';

/// Implementation of [MediaPickerService]
class MediaPickerServiceImpl implements MediaPickerService {
  MediaPickerServiceImpl({
    required MediaPermissionHandler permissionHandler,
    ImagePicker? imagePicker,
  }) : _permissionHandler = permissionHandler,
       _imagePicker = imagePicker ?? ImagePicker();

  final MediaPermissionHandler _permissionHandler;
  final ImagePicker _imagePicker;

  @override
  Future<MediaPickResult> pickImage({bool fromCamera = false}) async {
    try {
      // 1. Check Permissions
      final hasPermission = fromCamera
          ? await _permissionHandler.requestCameraPermission()
          : await _permissionHandler.requestGalleryPermission();

      if (!hasPermission) {
        final isPermanentlyDenied = fromCamera
            ? await _permissionHandler.isCameraPermanentlyDenied()
            : await _permissionHandler.isGalleryPermanentlyDenied();

        return isPermanentlyDenied
            ? const MediaPickPermissionPermanentlyDenied()
            : const MediaPickPermissionDenied();
      }

      // 2. Pick Image
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile == null) {
        return const MediaPickCancelled();
      }

      return MediaPickSuccess([File(pickedFile.path)]);
    } catch (e) {
      return MediaPickError(e.toString());
    }
  }

  @override
  Future<MediaPickResult> pickFiles({bool multiple = false}) async {
    try {
      // 1. Check Permissions
      // Note: FilePicker handles some permissions internally on some OS versions,
      // but explicit check is safer for consistency.
      final hasPermission = await _permissionHandler.requestStoragePermission();

      if (!hasPermission) {
        // Specialized logic might be needed here depending on OS version
        // For now we treat storage denial as a hard stop
        return const MediaPickPermissionDenied();
      }

      // 2. Pick Files
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: multiple,
      );

      if (result == null) {
        return const MediaPickCancelled();
      }

      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (files.isEmpty) {
        return const MediaPickError('File selection failed');
      }

      return MediaPickSuccess(files);
    } catch (e) {
      return MediaPickError(e.toString());
    }
  }
}
