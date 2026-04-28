import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: appSurface,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: appMuted, size: 24),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: appSurface,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: appSurface,
        child: const Center(
          child: Icon(Icons.broken_image, color: appMuted, size: 24),
        ),
      ),
    );
  }
}
