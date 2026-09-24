/// Sanitizer utility for extracting clean song title and artist from noisy video titles.
class TrackTitleSanitizer {
  const TrackTitleSanitizer();

  /// Regex pattern to strip parenthetical and bracketed concert, tour, live, and video noise
  static final RegExp _bracketNoiseRegex = RegExp(
    r'\s*[\[\(](?:Official|Lyric|Music|Audio|Video|HD|4K|Remastered|Live|Tour|Concert|Festival|En Vivo|Acoustic|Session|At\s+.*|Recorded\s+.*|Rock Werchter|Hellfest|Hyde Park|Late Night|Camp Krim|Dick Clark|Summer Sonic|Induction|Reunion|\d{4}).*?[\]\)]',
    caseSensitive: false,
  );

  /// Strips pipe separators and trailing broadcast/channel credits (e.g., "| Late Night with Conan...")
  static final RegExp _pipeRegex = RegExp(r'\s*\|.*$');

  /// Strips unbracketed trailing live video tags (e.g., "1999 Live Video", "Live Video", "Live at Camp Krim...")
  static final RegExp _unbracketedLiveRegex = RegExp(
    r'\s+(?:(?:\d{4}\s+)?Live\s+Video|Live\s+Reunion|Live(?:\s+At\s+.*)?)$',
    caseSensitive: false,
  );

  /// Cleans and extracts `{'artist': ..., 'title': ...}` from raw video title and fallback author
  Map<String, String> parse(String rawTitle, String fallbackAuthor) {
    final cleanAuthor = cleanArtistName(fallbackAuthor);
    var working = rawTitle.replaceAll(_pipeRegex, '').trim();

    // Pattern 1: Performance with quotes: e.g. Radiohead Perform "Creep" Live on...
    final performRegex = RegExp(
      r'^(.+?)\s+Perform(?:s)?\s+[""“](.+?)[""”]',
      caseSensitive: false,
    );
    final performMatch = performRegex.firstMatch(working);
    if (performMatch != null) {
      final artist = cleanArtistName(performMatch.group(1)!);
      final title = cleanTitle(performMatch.group(2)!);
      if (artist.isNotEmpty && title.isNotEmpty) {
        return {'artist': artist, 'title': title};
      }
    }

    // Pattern 2: Quoted title with optional delimiter: e.g.
    // "Bon Jovi “Livin’ on a Prayer” Live Reunion" or '4 Non Blondes - "What's Up" [2026...]'
    final quotedTitleRegex = RegExp(r'^(.+?)(?:\s+[—–-]\s+|\s+)[""“](.+?)[""”]');
    final quotedMatch = quotedTitleRegex.firstMatch(working);
    if (quotedMatch != null) {
      final artist = cleanArtistName(quotedMatch.group(1)!);
      final title = cleanTitle(quotedMatch.group(2)!);
      if (artist.isNotEmpty && title.isNotEmpty) {
        return {'artist': artist, 'title': title};
      }
    }

    // Pattern 3: Standard whitespace-padded delimiter: "Artist - Title" or "Title - Artist"
    // Use cleanWorking to prevent hyphens inside bracket noise from breaking delimiter splitting
    final cleanWorking = cleanTitle(working);
    final spacedDelimiter = RegExp(r'\s+[—–-]\s+');
    final spacedMatch = spacedDelimiter.firstMatch(cleanWorking);
    if (spacedMatch != null) {
      final part1 = cleanWorking.substring(0, spacedMatch.start).trim();
      final part2 = cleanWorking.substring(spacedMatch.end).trim();

      // Check if part2 is the artist (e.g. "Numb - Linkin Park" where channel is Linkin Park)
      final normPart2 = part2.toLowerCase();
      final normAuthor = cleanAuthor.toLowerCase();
      if (normAuthor.isNotEmpty && normPart2 == normAuthor) {
        return {
          'artist': cleanArtistName(part2),
          'title': cleanTitle(part1),
        };
      }

      if (normAuthor.isNotEmpty && part1.toLowerCase() == normAuthor) {
        return {
          'artist': cleanArtistName(part1),
          'title': cleanTitle(part2),
        };
      }

      // Check for live/tour indicators in part1 vs part2
      final liveKeywords = RegExp(r'Tour|Concert|Live|Festival', caseSensitive: false);
      if (part1.contains(liveKeywords) && !part2.contains(liveKeywords)) {
        return {
          'artist': cleanArtistName(part2),
          'title': cleanTitle(part1),
        };
      }

      return {
        'artist': cleanArtistName(part1),
        'title': cleanTitle(part2),
      };
    }

    // Pattern 4: Unspaced hyphen chains (e.g. "Goo Goo Dolls-Iris-Live At Camp Krim...")
    // Only apply if 3+ parts and at least one part contains spaces to avoid breaking words like "Anti-Hero"
    final unspacedParts = working.split('-');
    if (unspacedParts.length >= 3 && unspacedParts.any((p) => p.trim().contains(' '))) {
      final artist = cleanArtistName(unspacedParts[0]);
      final title = cleanTitle(unspacedParts[1]);
      if (artist.isNotEmpty && title.isNotEmpty) {
        return {'artist': artist, 'title': title};
      }
    }

    // Fallback: Use author name as artist and clean full title
    final artist = cleanAuthor.isEmpty ? 'Unknown Artist' : cleanAuthor;
    final title = cleanTitle(working);

    return {
      'artist': artist,
      'title': title.isEmpty ? rawTitle : title,
    };
  }

  /// Cleans a song title by removing bracketed noise, unbracketed live suffixes, and quotes
  String cleanTitle(String title) {
    var cleaned = title
        .replaceAll(_bracketNoiseRegex, '')
        .replaceAll(_unbracketedLiveRegex, '')
        .replaceAll(RegExp(r'^[""“]|[""”]$'), '')
        .trim();

    return cleaned.isEmpty ? title.trim() : cleaned;
  }

  /// Cleans an artist name by removing common channel/VEVO suffixes and trailing dashes
  String cleanArtistName(String artist) {
    return artist
        .replaceAll(RegExp(r'VEVO$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '')
        .replaceAll(RegExp(r'^[""“]|[""”]$'), '')
        .replaceAll(RegExp(r'\s*[-—–]\s*$'), '')
        .trim();
  }
}
