/// Normalized response object containing translated text and status
class TranslationResponse {
  final String translatedText;
  final int statusCode;
  final String? statusDetails;

  const TranslationResponse({
    required this.translatedText,
    required this.statusCode,
    this.statusDetails,
  });

  bool get isSuccessful => statusCode == 200 && translatedText.isNotEmpty;

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['responseData'] as Map<String, dynamic>?;
    final translated = responseData?['translatedText'] as String? ?? '';
    final status = json['responseStatus'] is int
        ? json['responseStatus'] as int
        : int.tryParse(json['responseStatus']?.toString() ?? '200') ?? 200;
    final details = json['responseDetails'] as String?;

    return TranslationResponse(
      translatedText: translated,
      statusCode: status,
      statusDetails: details,
    );
  }
}

