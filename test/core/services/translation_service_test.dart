import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/translation/translation.dart';
import 'package:setlist_pad/core/services/services.dart';

void main() {
  group('TranslationService Tests', () {
    late Directory tempDir;
    late Box<String> cacheBox;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_trans_test_');
      Hive.init(tempDir.path);
      cacheBox = await Hive.openBox<String>('test_trans_box');
    });

    tearDown(() async {
      await cacheBox.close();
      await Hive.deleteBoxFromDisk('test_trans_box');
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('translates lines without desynchronizing order and caches result',
        () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        final q = request.url.queryParameters['q'];
        String translated;
        if (q == 'Hello') {
          translated = 'Hola';
        } else if (q == 'World') {
          translated = 'Mundo';
        } else {
          translated = 'Traducción';
        }
        return http.Response(
          jsonEncode({
            'responseData': {'translatedText': translated},
            'responseStatus': 200,
          }),
          200,
        );
      });

      final translationClient = TranslationClient(client: mockClient);
      final service = TranslationService(
        client: translationClient,
        cacheBox: cacheBox,
      );

      const lyrics = 'Hello\n\nWorld';

      // First call - should call API
      final lines1 = await service.translateLyrics(
        lyrics: lyrics,
        targetLanguage: 'es',
        songId: 'song-123',
      );

      expect(lines1.length, 3);
      expect(lines1[0].original, 'Hello');
      expect(lines1[0].translation, 'Hola');
      expect(lines1[1].isBlank, isTrue);
      expect(lines1[2].original, 'World');
      expect(lines1[2].translation, 'Mundo');
      expect(callCount, 2); // 'Hello' and 'World'

      // Check cache is populated
      final cacheKey = service.computeCacheKey(
        songId: 'song-123',
        lyrics: lyrics,
        targetLanguage: 'es',
      );
      expect(cacheBox.get(cacheKey), 'Hola\n\nMundo');

      // Second call - should use cache with 0 additional calls
      final lines2 = await service.translateLyrics(
        lyrics: lyrics,
        targetLanguage: 'es',
        songId: 'song-123',
      );

      expect(callCount, 2); // Unchanged!
      expect(lines2.length, 3);
      expect(lines2[0].translation, 'Hola');
      expect(lines2[2].translation, 'Mundo');
    });

    test('clearCache deletes cached translation from Hive', () async {
      final service = TranslationService(
        cacheBox: cacheBox,
      );

      final key = service.computeCacheKey(
        songId: 'song-99',
        lyrics: 'Some text',
        targetLanguage: 'fr',
      );
      await cacheBox.put(key, 'Du texte');
      expect(cacheBox.containsKey(key), isTrue);

      await service.clearCache(
        songId: 'song-99',
        lyrics: 'Some text',
        targetLanguage: 'fr',
      );
      expect(cacheBox.containsKey(key), isFalse);
    });

    test('graceful fallback on API error without throwing', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final translationClient = TranslationClient(client: mockClient);
      final service = TranslationService(
        client: translationClient,
        cacheBox: cacheBox,
      );

      final lines = await service.translateLyrics(
        lyrics: 'Line 1\nLine 2',
        targetLanguage: 'es',
      );

      expect(lines.length, 2);
      expect(lines[0].original, 'Line 1');
      expect(lines[0].hasTranslation, isFalse);
      expect(lines[1].original, 'Line 2');
    });

    test('different lyrics revisions produce distinct cache keys', () {
      final service = TranslationService(cacheBox: cacheBox);
      final key1 = service.computeCacheKey(
        songId: 'song-1',
        lyrics: 'Original lyrics version 1',
        targetLanguage: 'es',
      );
      final key2 = service.computeCacheKey(
        songId: 'song-1',
        lyrics: 'Updated lyrics version 2 with new chords',
        targetLanguage: 'es',
      );
      expect(key1, isNot(equals(key2)));
    });

    test('partial translation failure does not cache incomplete results',
        () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        final q = request.url.queryParameters['q'];
        if (q == 'Line 1') {
          return http.Response(
            jsonEncode({
              'responseData': {'translatedText': 'Línea 1'},
              'responseStatus': 200,
            }),
            200,
          );
        }
        // Second line fails
        return http.Response('Internal Error', 500);
      });

      final translationClient = TranslationClient(client: mockClient);
      final service = TranslationService(
        client: translationClient,
        cacheBox: cacheBox,
      );

      const lyrics = 'Line 1\nLine 2';
      final cacheKey = service.computeCacheKey(
        songId: 'song-partial',
        lyrics: lyrics,
        targetLanguage: 'es',
      );

      final lines = await service.translateLyrics(
        lyrics: lyrics,
        targetLanguage: 'es',
        songId: 'song-partial',
      );

      expect(callCount, 2);
      expect(lines.length, 2);
      expect(lines[0].translation, 'Línea 1');
      expect(lines[1].hasTranslation, isFalse);

      // Verify incomplete result was NOT cached
      expect(cacheBox.containsKey(cacheKey), isFalse);
    });

    test('returns empty list for empty lyrics', () async {
      final service = TranslationService(cacheBox: cacheBox);
      final lines = await service.translateLyrics(
        lyrics: '   ',
        targetLanguage: 'es',
      );
      expect(lines, isEmpty);
    });
  });
}

