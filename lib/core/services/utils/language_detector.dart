/// Pure utility for heuristically detecting natural language from song lyrics
class LanguageDetector {
  const LanguageDetector();

  static const Map<String, Set<String>> _stopwords = {
    'es': {
      'de', 'la', 'que', 'el', 'en', 'y', 'los', 'se', 'del', 'las',
      'por', 'un', 'con', 'una', 'su', 'al', 'es', 'pero', 'para', 'como',
      'yo', 'tu', 'mi', 'corazon', 'amor', 'vida', 'todo', 'nada', 'mas',
    },
    'en': {
      'the', 'and', 'to', 'a', 'in', 'is', 'you', 'of', 'it', 'that',
      'me', 'on', 'with', 'all', 'my', 'at', 'be', 'this', 'from', 'we',
      'your', 'for', 'not', 'have', 'are', 'was', 'like', 'love', 'know',
    },
    'pt': {
      'de', 'que', 'do', 'da', 'em', 'um', 'para', 'com', 'nao', 'uma',
      'os', 'no', 'se', 'na', 'por', 'mais', 'as', 'dos', 'como', 'mas',
      'eu', 'meu', 'voce', 'coracao', 'amor', 'tudo', 'vida',
    },
    'fr': {
      'de', 'la', 'le', 'et', 'les', 'des', 'en', 'un', 'du', 'une',
      'que', 'est', 'pour', 'dans', 'qui', 'ne', 'sur', 'se', 'pas',
      'plus', 'je', 'mon', 'moi', 'avec', 'tout', 'amour', 'vie',
    },
    'it': {
      'di', 'che', 'la', 'il', 'un', 'per', 'una', 'in', 'sono', 'mi',
      'si', 'ho', 'ma', 'ha', 'del', 'da', 'ed', 'non', 'io', 'mio',
      'tuo', 'amore', 'vita', 'cuore', 'tutto', 'come',
    },
    'de': {
      'der', 'die', 'und', 'in', 'den', 'von', 'zu', 'das', 'mit', 'sich',
      'des', 'auf', 'fur', 'ist', 'im', 'dem', 'nicht', 'ein', 'eine',
      'als', 'auch', 'es', 'an', 'wir', 'ich', 'du', 'mein', 'liebe',
    },
  };

  /// Heuristically detects the ISO 639-1 language code from [text].
  /// Guarantees returning a valid ISO code that differs from [targetLanguage].
  String detectLanguage(String text, {String? targetLanguage}) {
    final cleanTarget = targetLanguage?.toLowerCase().trim();
    final fallback = cleanTarget == 'en' ? 'es' : 'en';

    if (text.trim().isEmpty) {
      return fallback;
    }

    // Normalize text into words
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), ' ');
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return fallback;
    }

    final scores = <String, int>{
      'es': 0,
      'en': 0,
      'pt': 0,
      'fr': 0,
      'it': 0,
      'de': 0,
    };

    for (final token in tokens) {
      for (final entry in _stopwords.entries) {
        if (entry.value.contains(token)) {
          scores[entry.key] = (scores[entry.key] ?? 0) + 1;
        }
      }
    }

    // Diacritics weighting bonus
    if (text.contains(RegExp(r'[¿¡ñáéíóú]'))) scores['es'] = (scores['es'] ?? 0) + 3;
    if (text.contains(RegExp(r'[ãõçê]'))) scores['pt'] = (scores['pt'] ?? 0) + 3;
    if (text.contains(RegExp(r'[èéêàçù]'))) scores['fr'] = (scores['fr'] ?? 0) + 3;
    if (text.contains(RegExp(r'[äöüß]'))) scores['de'] = (scores['de'] ?? 0) + 3;

    // Sort by highest score
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      if (entry.value > 0 && entry.key != cleanTarget) {
        return entry.key;
      }
    }

    return fallback;
  }
}

