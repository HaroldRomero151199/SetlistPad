import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/services.dart';

void main() {
  group('LanguageDetector Tests', () {
    const detector = LanguageDetector();

    test('detects Spanish lyrics with Spanish stopwords and diacritics', () {
      const spanishLyrics =
          'De la noche a la mañana, que el corazón se rompe con una mirada y amor.';
      final result = detector.detectLanguage(spanishLyrics, targetLanguage: 'en');
      expect(result, 'es');
    });

    test('detects English lyrics with English stopwords', () {
      const englishLyrics =
          'Look at the stars, look how they shine for you and everything you do.';
      final result = detector.detectLanguage(englishLyrics, targetLanguage: 'es');
      expect(result, 'en');
    });

    test('detects Portuguese lyrics with Portuguese stopwords and diacritics', () {
      const portugueseLyrics =
          'Eu não sei o que fazer com meu coração, tudo que eu quero é você.';
      final result = detector.detectLanguage(portugueseLyrics, targetLanguage: 'es');
      expect(result, 'pt');
    });

    test('detects French lyrics with French stopwords and accents', () {
      const frenchLyrics =
          'Pour tout ce que je suis avec toi et pour la vie, dans mon cœur.';
      final result = detector.detectLanguage(frenchLyrics, targetLanguage: 'es');
      expect(result, 'fr');
    });

    test('detects German lyrics with German stopwords and umlauts', () {
      const germanLyrics =
          'Du und ich, wir sind in der Nacht mit Liebe für immer und nicht allein.';
      final result = detector.detectLanguage(germanLyrics, targetLanguage: 'es');
      expect(result, 'de');
    });

    test('detects Italian lyrics with Italian stopwords', () {
      const italianLyrics =
          'Non ho niente da dire, tutto il mio amore è per te nella vita.';
      final result = detector.detectLanguage(italianLyrics, targetLanguage: 'es');
      expect(result, 'it');
    });

    test('returns different language from targetLanguage on empty text', () {
      expect(detector.detectLanguage('', targetLanguage: 'es'), 'en');
      expect(detector.detectLanguage('', targetLanguage: 'en'), 'es');
    });

    test('swaps to fallback if detected language matches targetLanguage', () {
      const englishLyrics = 'The world is mine and you know it';
      // When target is 'en', detector must not return 'en'
      final result = detector.detectLanguage(englishLyrics, targetLanguage: 'en');
      expect(result, isNot('en'));
    });
  });
}

