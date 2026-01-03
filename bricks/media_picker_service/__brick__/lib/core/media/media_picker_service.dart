import 'media_pick_result.dart';

/// Service for picking platform media (images, files)
abstract class MediaPickerService {
  /// Pick an image from gallery or camera
  ///
  /// [fromCamera] - If true, launches camera directly
  Future<MediaPickResult> pickImage({bool fromCamera = false});

  /// Pick generic files from storage
  Future<MediaPickResult> pickFiles({bool multiple = false});
}
