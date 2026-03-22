/// Client-side bad-words filter for chat messages and user content.
class BadWordsFilter {
  BadWordsFilter._();

  // Common offensive words list (extend as needed).
  static final Set<String> _badWords = {
    'fuck', 'shit', 'ass', 'bitch', 'damn', 'bastard', 'dick', 'piss',
    'crap', 'slut', 'whore', 'idiot', 'stupid', 'moron', 'retard',
    'nigger', 'faggot', 'cunt', 'cock', 'porn', 'sex', 'nude', 'naked',
    'hentai', 'xxx', 'anal', 'boob', 'penis', 'vagina',
  };

  /// Returns `true` if the text contains any bad words.
  static bool containsBadWords(String text) {
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'[\s,.\-!?;:]+'));
    return words.any((w) => _badWords.contains(w));
  }

  /// Replace bad words with asterisks (e.g. "f***").
  static String censor(String text) {
    String result = text;
    for (final word in _badWords) {
      final pattern = RegExp(
        '\\b$word\\b',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(pattern, (m) {
        final matched = m.group(0)!;
        if (matched.length <= 1) return '*';
        return matched[0] + '*' * (matched.length - 1);
      });
    }
    return result;
  }

  /// Add custom words to the filter at runtime.
  static void addWords(Iterable<String> words) {
    _badWords.addAll(words.map((w) => w.toLowerCase()));
  }
}
