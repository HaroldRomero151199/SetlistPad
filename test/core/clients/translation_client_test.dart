import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/clients.dart';

void main() {
  group('TranslationClient Tests', () {
    test('translate returns TranslationResponse on 200 status', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['q'], 'Hello World');
        expect(request.url.queryParameters['langpair'], 'autodetect|es');
        return http.Response(
          jsonEncode({
            'responseData': {'translatedText': 'Hola Mundo', 'match': 1},
            'responseStatus': 200,
          }),
          200,
        );
      });

      final client = TranslationClient(client: mockClient);
      final response = await client.translate(
        const TranslationRequest(text: 'Hello World', targetLanguage: 'es'),
      );

      expect(response, isNotNull);
      expect(response!.isSuccessful, isTrue);
      expect(response.translatedText, 'Hola Mundo');
      expect(response.statusCode, 200);
    });

    test('translate returns empty text without HTTP call when text is empty',
        () async {
      var called = false;
      final mockClient = MockClient((request) async {
        called = true;
        return http.Response('', 200);
      });

      final client = TranslationClient(client: mockClient);
      final response = await client.translate(
        const TranslationRequest(text: '   ', targetLanguage: 'es'),
      );

      expect(called, isFalse);
      expect(response, isNotNull);
      expect(response!.translatedText, '');
    });

    test('translate returns null on 4xx/5xx status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final client = TranslationClient(client: mockClient);
      final response = await client.translate(
        const TranslationRequest(text: 'Hello', targetLanguage: 'es'),
      );

      expect(response, isNull);
    });

    test('translate returns null on client exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network disconnected');
      });

      final client = TranslationClient(client: mockClient);
      final response = await client.translate(
        const TranslationRequest(text: 'Hello', targetLanguage: 'es'),
      );

      expect(response, isNull);
    });

    test('translateText returns translated string directly', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'responseData': {'translatedText': 'Bonjour'},
            'responseStatus': 200,
          }),
          200,
        );
      });

      final client = TranslationClient(client: mockClient);
      final text = await client.translateText(
        text: 'Hello',
        targetLanguage: 'fr',
      );

      expect(text, 'Bonjour');
    });
  });
}

