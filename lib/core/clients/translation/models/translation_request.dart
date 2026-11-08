/// Request parameters for translating text between languages
class TranslationRequest {
  final String text;
  final String targetLanguage;
  final String sourceLanguage;

  const TranslationRequest({
    required this.text,
    required this.targetLanguage,
    required this.sourceLanguage,
  });

  Map<String, String> toQueryParams() {
    return {
      'q': text,
      'langpair': '$sourceLanguage|$targetLanguage',
    };
  }
}
