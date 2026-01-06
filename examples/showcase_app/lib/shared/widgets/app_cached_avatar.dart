import 'package:flutter/material.dart';

import 'app_cached_image.dart';

/// Circular avatar variant of AppCachedImage
///
/// Convenience widget for profile pictures and user avatars
class AppCachedAvatar extends StatelessWidget {
  const AppCachedAvatar({
    required this.imageUrl,
    super.key,
    this.size = 48,
    this.placeholder,
    this.fallbackIcon = Icons.person,
    this.enableRetry = true,
  });

  /// URL of the avatar image
  final String imageUrl;

  /// Size of the avatar (both width and height)
  final double size;

  /// Custom placeholder widget
  final Widget? placeholder;

  /// Fallback icon when no image or error
  final IconData fallbackIcon;

  /// Enable tap-to-retry on error
  final bool enableRetry;

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      shape: BoxShape.circle,
      placeholder: placeholder,
      enableRetry: enableRetry,
      errorWidget: _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
