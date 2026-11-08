/// Domain model representing a single pair of an original lyrics line and its translation
class BilingualLine {
  final int lineNumber;
  final String original;
  final String? translation;

  const BilingualLine({
    required this.lineNumber,
    required this.original,
    this.translation,
  });

  /// Indicates if this line is an empty line or spacing between stanzas
  bool get isBlank => original.trim().isEmpty;

  /// Indicates if a non-empty translation is present for this line
  bool get hasTranslation =>
      translation != null && translation!.trim().isNotEmpty;

  /// Returns the translated text if available, or the original line as fallback
  String get effectiveTranslation =>
      hasTranslation ? translation! : original;

  BilingualLine copyWith({
    int? lineNumber,
    String? original,
    String? translation,
  }) {
    return BilingualLine(
      lineNumber: lineNumber ?? this.lineNumber,
      original: original ?? this.original,
      translation: translation ?? this.translation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BilingualLine &&
        other.lineNumber == lineNumber &&
        other.original == original &&
        other.translation == translation;
  }

  @override
  int get hashCode => Object.hash(lineNumber, original, translation);

  @override
  String toString() =>
      'BilingualLine(lineNumber: $lineNumber, original: "$original", translation: "$translation")';
}

