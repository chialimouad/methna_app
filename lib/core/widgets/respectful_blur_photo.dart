import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';

/// Respectful Blur System — photos are blurred based on interaction level.
/// - Level 0 (stranger): heavy blur (sigma 18)
/// - Level 1 (liked): medium blur (sigma 8)
/// - Level 2 (matched): no blur
///
/// The blur gracefully lifts as interaction deepens,
/// respecting Islamic values of modesty.
class RespectfulBlurPhoto extends StatelessWidget {
  final String? imageUrl;
  final int interactionLevel; // 0 = stranger, 1 = liked, 2 = matched
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const RespectfulBlurPhoto({
    super.key,
    required this.imageUrl,
    this.interactionLevel = 0,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  double get _blurSigma {
    switch (interactionLevel) {
      case 0: return 16.0;
      case 1: return 6.0;
      default: return 0.0;
    }
  }

  String get _blurLabel {
    switch (interactionLevel) {
      case 0: return 'Like to reveal';
      case 1: return 'Match to see clearly';
      default: return '';
    }
  }

  IconData get _blurIcon {
    switch (interactionLevel) {
      case 0: return Icons.visibility_off_rounded;
      case 1: return Icons.visibility_rounded;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _DefaultPlaceholder(width: width, height: height);
    }

    Widget image = CachedNetworkImage(
      imageUrl: CloudinaryUrl.medium(imageUrl),
      fit: fit,
      width: width,
      height: height,
      placeholder: (ctx, url) => placeholder ?? Container(
        width: width,
        height: height,
        color: const Color(0xFFEDE7F6),
      ),
      errorWidget: (ctx, url, err) => errorWidget ?? _DefaultPlaceholder(width: width, height: height),
    );

    // No blur for matched users
    if (interactionLevel >= 2) {
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: image);
      }
      return image;
    }

    // Apply blur
    Widget blurred = Stack(
      fit: StackFit.passthrough,
      children: [
        image,
        // Blur overlay
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
            child: Container(
              width: width,
              height: height,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Hint label
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_blurIcon, color: Colors.white.withValues(alpha: 0.9), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _blurLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: blurred);
    }
    return blurred;
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  const _DefaultPlaceholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEDE7F6),
      child: const Center(
        child: Icon(Icons.person, size: 40, color: Color(0xFFBDBDBD)),
      ),
    );
  }
}
