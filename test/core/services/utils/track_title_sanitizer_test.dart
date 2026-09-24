import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/utils/track_title_sanitizer.dart';

void main() {
  group('TrackTitleSanitizer Tests', () {
    const sanitizer = TrackTitleSanitizer();

    test('parses standard Artist - Title with concert noise', () {
      final res = sanitizer.parse(
        'Air Supply - Making Love Out of Nothing at All (Tour Concert - The Florida Theatre, Jacksonville)',
        'AirSupplyVEVO',
      );
      expect(res['artist'], 'Air Supply');
      expect(res['title'], 'Making Love Out of Nothing at All');
    });

    test('parses live event in parentheses', () {
      final res = sanitizer.parse('a-ha - Take On Me (Live 8 2005)', 'a-ha');
      expect(res['artist'], 'a-ha');
      expect(res['title'], 'Take On Me');
    });

    test('parses unbracketed live video suffix', () {
      final res = sanitizer.parse('The Cranberries - Zombie 1999 Live Video', 'TheCranberriesVEVO');
      expect(res['artist'], 'The Cranberries');
      expect(res['title'], 'Zombie');
    });

    test('parses festival tag in parentheses', () {
      final res = sanitizer.parse('Keane - Somewhere Only We Know (Live @ Rock Werchter 2022)', 'Keane');
      expect(res['artist'], 'Keane');
      expect(res['title'], 'Somewhere Only We Know');
    });

    test('parses city and venue details in parentheses', () {
      final res = sanitizer.parse('Linkin Park - In The End (Live at Summer Sonic, Tokyo Japan, 2013)', 'Linkin Park');
      expect(res['artist'], 'Linkin Park');
      expect(res['title'], 'In The End');
    });

    test('parses reversed Title (Tour) - Artist format', () {
      final res = sanitizer.parse('Numb (2017 One More Light World Tour - Amsterdam) - Linkin Park', 'Linkin Park');
      expect(res['artist'], 'Linkin Park');
      expect(res['title'], 'Numb');
    });

    test('parses date and festival in parentheses', () {
      final res = sanitizer.parse('Scorpions - Wind Of Change (Live At Hellfest, 20.06.2015)', 'Scorpions');
      expect(res['artist'], 'Scorpions');
      expect(res['title'], 'Wind Of Change');
    });

    test('parses quote delimited title and pipe separator broadcast credits', () {
      final res = sanitizer.parse(
        'Bon Jovi “Livin’ on a Prayer” Live Reunion | Rock Hall 2018 Induction',
        'Rock & Roll Hall of Fame',
      );
      expect(res['artist'], 'Bon Jovi');
      expect(res['title'], 'Livin’ on a Prayer');
    });

    test('parses Perform verb pattern with TV show pipe separator', () {
      final res = sanitizer.parse(
        'Radiohead Perform "Creep" Live on September 14, 1993 | Late Night with Conan O’Brien',
        'Conan Classic',
      );
      expect(res['artist'], 'Radiohead');
      expect(res['title'], 'Creep');
    });

    test('parses unspaced hyphen chain', () {
      final res = sanitizer.parse('Goo Goo Dolls-Iris-Live At Camp Krim 8/15/13', 'Goo Goo Dolls');
      expect(res['artist'], 'Goo Goo Dolls');
      expect(res['title'], 'Iris');
    });

    test('parses quotes in title with New Year event bracket', () {
      final res = sanitizer.parse(
        '4 Non Blondes - "What\'s Up" [2026 Dick Clark\'s New Year\'s Rockin\' Eve]',
        'ABC',
      );
      expect(res['artist'], '4 Non Blondes');
      expect(res['title'], "What's Up");
    });

    test('parses Opus Live is Life with Live tag', () {
      final res = sanitizer.parse('Opus - Live is Life [Live 2002]', 'Opus');
      expect(res['artist'], 'Opus');
      expect(res['title'], 'Live is Life');
    });
  });
}
