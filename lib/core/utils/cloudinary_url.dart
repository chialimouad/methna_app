/// Cloudinary URL transformation helper for optimized image delivery.
///
/// Inserts Cloudinary transformations into existing URLs to serve
/// appropriately sized images for different UI contexts, saving bandwidth.
class CloudinaryUrl {
  CloudinaryUrl._();

  /// Thumbnail: 150x150, face-aware crop, aggressive compression.
  /// Use for: avatars, small list tiles, online user indicators.
  static String thumbnail(String? url) =>
      _transform(url, 'w_150,h_150,c_thumb,g_face,f_auto,q_auto:low');

  /// Medium: 400x400, auto quality.
  /// Use for: grid cards, user cards, category user tiles.
  static String medium(String? url) =>
      _transform(url, 'w_400,h_400,c_limit,f_auto,q_auto:good');

  /// Large: 800x800, high quality.
  /// Use for: swipe cards, detail view hero images.
  static String large(String? url) =>
      _transform(url, 'w_800,h_800,c_limit,f_auto,q_auto:good');

  /// Full: original size with auto format/quality only.
  /// Use for: photo viewer, zoom.
  static String full(String? url) =>
      _transform(url, 'f_auto,q_auto:good');

  /// Custom resize: specific width.
  static String getResizedUrl(String? url, {int width = 800}) =>
      _transform(url, 'w_$width,c_limit,f_auto,q_auto:good');

  /// Insert transformation into a Cloudinary URL.
  /// If the URL is null, empty, or not a Cloudinary URL, returns it as-is.
  static String _transform(String? url, String transform) {
    if (url == null || url.isEmpty) return url ?? '';
    if (!url.contains('/upload/')) return url;
    return url.replaceFirst('/upload/', '/upload/$transform/');
  }
}
