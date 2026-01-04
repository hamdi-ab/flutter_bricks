# network_image_widget Brick

A robust, feature-rich cached network image widget with progress indicator, retry mechanism, and fade animations.

## Features

- **Disk & Memory Caching**: Powered by `cached_network_image`
- **Download Progress**: Visual progress indicator during load
- **Tap-to-Retry**: User can retry failed loads
- **Fade-In Animation**: Smooth appearance when image loads
- **Shape Support**: Rectangle, rounded corners, or circle
- **Memory Optimization**: Optional memory cache constraints
- **Avatar Variant**: Convenience widget for profile pictures

## Generated Files

| File | Description |
|------|-------------|
| `app_cached_image.dart` | Main image widget with all features |
| `app_cached_avatar.dart` | Circular avatar convenience widget |

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

## Usage Examples

### Basic Usage

```dart
AppCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
)
```

### Rounded Corners

```dart
AppCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  borderRadius: BorderRadius.circular(16),
)
```

### Circular Image

```dart
AppCachedImage(
  imageUrl: 'https://example.com/avatar.jpg',
  width: 80,
  height: 80,
  shape: BoxShape.circle,
)
```

### User Avatar

```dart
AppCachedAvatar(
  imageUrl: user.avatarUrl,
  size: 48,
  fallbackIcon: Icons.person,
)
```

### With Custom Placeholder

```dart
AppCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  showProgress: false,
  placeholder: Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
)
```

### Without Retry

```dart
AppCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  enableRetry: false,
  errorWidget: const Icon(Icons.image_not_supported),
)
```

### Memory Optimized (for lists)

```dart
ListView.builder(
  itemBuilder: (context, index) => AppCachedImage(
    imageUrl: images[index],
    width: 100,
    height: 100,
    memCacheWidth: 200, // 2x for retina
    memCacheHeight: 200,
  ),
)
```
