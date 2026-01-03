# media_picker_service Brick

A Mason brick that scaffolds a robust, reusable service for picking images and files in Flutter apps. It handles permissions, normalizes results, and abstracts away platform plugins.

## Features

- **Unified Result Type**: `MediaPickResult` sealed class (Success, Denied, PermanentlyDenied, Cancelled).
- **Permission Handling**: Abstracts `permission_handler` logic (Camera, Gallery, Storage).
- **Service Layer**: Decouples UI from `image_picker` and `file_picker`.
- **Pure Dart**: No UI code or ViewModels included.

## Generated Files

| File | Description |
|------|-------------|
| `media_pick_result.dart` | Sealed class representing the outcome. |
| `media_permission_handler.dart` | Abstract permission interface. |
| `media_permission_handler_impl.dart` | Concrete permission logic. |
| `media_picker_service.dart` | Abstract service interface. |
| `media_picker_service_impl.dart` | Concrete implementation using plugins. |

## Usage

1. **Add Dependencies**:
   Add these packages to your `pubspec.yaml`:
   ```yaml
   image_picker: ^1.0.4
   file_picker: ^6.1.1
   permission_handler: ^11.0.0
   ```
   *(Note: Setup platform-specific permissions in AndroidManifest.xml and Info.plist as per package docs)*

2. **Generate Code**:
   ```bash
   mason make media_picker_service
   ```

3. **Register in DI (Riverpod Example)**:
   ```dart
   final mediaPermissionHandlerProvider = Provider<MediaPermissionHandler>(
     (ref) => MediaPermissionHandlerImpl(),
   );

   final mediaPickerServiceProvider = Provider<MediaPickerService>(
     (ref) => MediaPickerServiceImpl(
       permissionHandler: ref.watch(mediaPermissionHandlerProvider),
     ),
   );
   ```

4. **Use in ViewModel**:
   ```dart
   Future<void> pickProfileImage() async {
     final result = await _mediaPickerService.pickImage(fromCamera: false);
     
     switch (result) {
       case MediaPickSuccess(files: final files):
         // Handle file
         break;
       case MediaPickPermissionDenied():
         // Explain why permission is needed
         break;
       case MediaPickPermissionPermanentlyDenied():
         // Suggest opening settings
         break;
       // ... handle other cases
     }
   }
   ```
