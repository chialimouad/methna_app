/// Utility for sanitizing user inputs before sending to the backend.
class InputSanitizer {
  InputSanitizer._();

  /// Strip leading/trailing whitespace and collapse internal runs.
  static String trimAndCollapse(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Remove HTML / script tags.
  static String stripHtml(String input) =>
      input.replaceAll(RegExp(r'<[^>]*>'), '');

  /// Remove special characters that could be used for injection.
  static String stripInjection(String input) =>
      input.replaceAll(RegExp(r'[<>{}()\[\]\\\/;$`]'), '');

  /// Full sanitization pipeline for general text fields.
  static String sanitize(String input) =>
      stripInjection(stripHtml(trimAndCollapse(input)));

  /// Sanitize an email address (lowercase + trim).
  static String sanitizeEmail(String input) =>
      input.trim().toLowerCase();

  /// Sanitize a username (lowercase, trim, strip non-alphanumeric except _ and .).
  static String sanitizeUsername(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_.]'), '');
}
