import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageWithPlaceholder extends StatelessWidget {
  const ImageWithPlaceholder({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image,
    this.errorIcon = Icons.broken_image,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final shape = borderRadius != null
        ? RoundedRectangleBorder(borderRadius: borderRadius!)
        : null;

    if (imageUrl == null || imageUrl!.isEmpty) {
      final placeholder = _Placeholder(
        width: width,
        height: height,
        icon: placeholderIcon,
        shape: shape,
      );
      if (borderRadius == null) return placeholder;
      return ClipRRect(borderRadius: borderRadius!, child: placeholder);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _ShimmerPlaceholder(
          width: width,
          height: height,
          shape: shape,
        ),
        errorWidget: (context, url, error) => _Placeholder(
          width: width,
          height: height,
          icon: errorIcon,
          shape: shape,
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({this.width, this.height, this.shape});
  final double? width;
  final double? height;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
        child: shape != null ? null : const Center(child: Icon(Icons.image, color: Colors.grey)),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height, required this.icon, this.shape});
  final double? width;
  final double? height;
  final IconData icon;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
