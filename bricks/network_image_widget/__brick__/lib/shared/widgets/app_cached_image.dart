import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A robust, feature-rich network image widget with caching
///
/// Features:
/// - Disk and memory caching via cached_network_image
/// - Download progress indicator
/// - Smooth fade-in animation
/// - Tap-to-retry on error
/// - Flexible placeholder and error widgets
/// - Support for shapes (rounded, circular, custom)
class AppCachedImage extends StatefulWidget {
  const AppCachedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.showProgress = true,
    this.enableRetry = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.headers,
  });

  /// URL of the image to load
  final String imageUrl;

  /// Width constraint
  final double? width;

  /// Height constraint
  final double? height;

  /// How the image should fit within bounds
  final BoxFit fit;

  /// Custom placeholder widget (overrides default progress)
  final Widget? placeholder;

  /// Custom error widget (overrides default retry button)
  final Widget? errorWidget;

  /// Border radius (only applies when shape is rectangle)
  final BorderRadius? borderRadius;

  /// Shape of the image container
  final BoxShape shape;

  /// Duration of the fade-in animation
  final Duration fadeInDuration;

  /// Show download progress indicator
  final bool showProgress;

  /// Enable tap-to-retry on error
  final bool enableRetry;

  /// Memory cache width (for memory optimization)
  final int? memCacheWidth;

  /// Memory cache height (for memory optimization)
  final int? memCacheHeight;

  /// Custom headers for the image request
  final Map<String, String>? headers;

  @override
  State<AppCachedImage> createState() => _AppCachedImageState();
}

class _AppCachedImageState extends State<AppCachedImage> {
  Key _imageKey = UniqueKey();

  void _retry() {
    setState(() {
      _imageKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return _buildErrorWidget(context, null);
    }

    Widget image = CachedNetworkImage(
      key: _imageKey,
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      httpHeaders: widget.headers,
      placeholder: (context, url) => _buildPlaceholder(context),
      progressIndicatorBuilder:
          widget.showProgress && widget.placeholder == null
          ? (context, url, progress) =>
                _buildProgressIndicator(context, progress)
          : null,
      errorWidget: (context, url, error) => _buildErrorWidget(context, error),
    );

    // Apply shape
    if (widget.shape == BoxShape.circle) {
      image = ClipOval(child: image);
    } else if (widget.borderRadius != null) {
      image = ClipRRect(borderRadius: widget.borderRadius!, child: image);
    }

    return SizedBox(width: widget.width, height: widget.height, child: image);
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) return widget.placeholder!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : widget.borderRadius,
        shape: widget.shape,
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    DownloadProgress progress,
  ) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : widget.borderRadius,
        shape: widget.shape,
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: progress.progress,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    if (widget.errorWidget != null) return widget.errorWidget!;

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.enableRetry ? _retry : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : widget.borderRadius,
          shape: widget.shape,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.error,
              size: 24,
            ),
            if (widget.enableRetry) ...[
              const SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
