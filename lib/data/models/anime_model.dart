import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeModel {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String coverUrl;
  final List<String> screenshots;
  final double rating;
  final int totalRatings;
  final DateTime releaseDate;
  final String studio;
  final int duration; // в минутах
  final String? trailerUrl;
  final List<String> tags;
  final bool isExclusive;
  final bool is18Plus;

  AnimeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.coverUrl,
    required this.screenshots,
    required this.rating,
    required this.totalRatings,
    required this.releaseDate,
    required this.studio,
    required this.duration,
    this.trailerUrl,
    required this.tags,
    this.isExclusive = false,
    this.is18Plus = true,
  });

  // Преобразование из Map (данные из Firestore)
  factory AnimeModel.fromMap(Map<String, dynamic> map) {
    return AnimeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      coverUrl: map['coverUrl'] ?? '',
      screenshots: List<String>.from(map['screenshots'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      releaseDate: (map['releaseDate'] as Timestamp).toDate(),
      studio: map['studio'] ?? '',
      duration: map['duration'] ?? 0,
      trailerUrl: map['trailerUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      isExclusive: map['isExclusive'] ?? false,
      is18Plus: map['is18Plus'] ?? true,
    );
  }

  // Преобразование в Map (для сохранения в Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genres': genres,
      'coverUrl': coverUrl,
      'screenshots': screenshots,
      'rating': rating,
      'totalRatings': totalRatings,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'studio': studio,
      'duration': duration,
      'trailerUrl': trailerUrl,
      'tags': tags,
      'isExclusive': isExclusive,
      'is18Plus': is18Plus,
    };
  }
}
