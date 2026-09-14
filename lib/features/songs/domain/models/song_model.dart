import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String? youtubeUrl;

  @HiveField(4)
  final String lyrics;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.youtubeUrl,
    required this.lyrics,
    required this.createdAt,
    required this.updatedAt,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? youtubeUrl,
    bool clearYoutubeUrl = false,
    String? lyrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      youtubeUrl: clearYoutubeUrl ? null : (youtubeUrl ?? this.youtubeUrl),
      lyrics: lyrics ?? this.lyrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'youtubeUrl': youtubeUrl,
      'lyrics': lyrics,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      youtubeUrl: json['youtubeUrl'] as String?,
      lyrics: json['lyrics'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
