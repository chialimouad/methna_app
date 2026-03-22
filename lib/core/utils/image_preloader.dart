import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Utility for preloading images to ensure smooth UI transitions.
class ImagePreloader {
  ImagePreloader._();

  /// Preload a single network image into the cache.
  static Future<void> preloadNetwork(BuildContext context, String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {
      // Silently fail – preloading is best-effort
    }
  }

  /// Preload multiple network images in parallel.
  static Future<void> preloadNetworkBatch(
    BuildContext context,
    List<String> urls,
  ) async {
    await Future.wait(
      urls.map((url) => preloadNetwork(context, url)),
      eagerError: false,
    );
  }

  /// Preload a local asset image.
  static Future<void> preloadAsset(BuildContext context, String asset) async {
    try {
      await precacheImage(AssetImage(asset), context);
    } catch (_) {}
  }

  /// Preload multiple asset images in parallel.
  static Future<void> preloadAssetBatch(
    BuildContext context,
    List<String> assets,
  ) async {
    await Future.wait(
      assets.map((a) => preloadAsset(context, a)),
      eagerError: false,
    );
  }
}
