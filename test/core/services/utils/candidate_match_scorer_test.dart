import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/clients/clients.dart';
import 'package:setlist_pad/core/services/utils/candidate_match_scorer.dart';

void main() {
  group('CandidateMatchScorer Tests', () {
    const scorer = CandidateMatchScorer();

    test('returns 1.0 for exact title and artist match', () {
      final score = scorer.computeScore(
        queryArtist: 'Air Supply',
        queryTitle: 'Making Love Out of Nothing at All',
        candidateArtist: 'Air Supply',
        candidateTitle: 'Making Love Out of Nothing at All',
      );
      expect(score, 1.0);
    });

    test('returns high score for case-insensitive and punctuation differences', () {
      final score = scorer.computeScore(
        queryArtist: 'bon jovi',
        queryTitle: "Livin' on a Prayer",
        candidateArtist: 'Bon Jovi',
        candidateTitle: 'Livin On A Prayer',
      );
      expect(score, greaterThan(0.85));
    });

    test('returns low score for mismatched artist and song', () {
      final score = scorer.computeScore(
        queryArtist: 'Coldplay',
        queryTitle: 'Yellow',
        candidateArtist: 'Radiohead',
        candidateTitle: 'Creep',
      );
      expect(score, lessThan(0.3));
    });

    test('findBestMatch selects candidate with highest matching score having lyrics', () {
      final candidates = [
        const LrclibResponse(
          artistName: 'Random Band',
          trackName: 'Some Song',
          plainLyrics: 'Completely different lyrics',
        ),
        const LrclibResponse(
          artistName: 'Air Supply',
          trackName: 'Making Love Out of Nothing at All',
          plainLyrics: 'I know just how to whisper...',
        ),
        const LrclibResponse(
          artistName: 'Air Supply',
          trackName: 'All Out of Love',
          plainLyrics: 'I am all out of love...',
        ),
      ];

      final best = scorer.findBestMatch(
        queryArtist: 'Air Supply',
        queryTitle: 'Making Love Out of Nothing at All',
        candidates: candidates,
      );

      expect(best, isNotNull);
      expect(best!.trackName, 'Making Love Out of Nothing at All');
      expect(best.plainLyrics, 'I know just how to whisper...');
    });

    test('findBestMatch ignores candidates without lyrics', () {
      final candidates = [
        const LrclibResponse(
          artistName: 'Air Supply',
          trackName: 'Making Love Out of Nothing at All',
          plainLyrics: '',
          syncedLyrics: null,
        ),
      ];

      final best = scorer.findBestMatch(
        queryArtist: 'Air Supply',
        queryTitle: 'Making Love Out of Nothing at All',
        candidates: candidates,
      );

      expect(best, isNull);
    });

    test('findBestMatch rejects candidates below threshold', () {
      final candidates = [
        const LrclibResponse(
          artistName: 'Totally Different Artist',
          trackName: 'Completely Unrelated Track',
          plainLyrics: 'Some lyrics',
        ),
      ];

      final best = scorer.findBestMatch(
        queryArtist: 'Air Supply',
        queryTitle: 'Making Love Out of Nothing at All',
        candidates: candidates,
        minThreshold: 0.50,
      );

      expect(best, isNull);
    });
  });
}
