import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime_model.dart';
import '../models/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить список аниме с пагинацией
  Future<List<AnimeModel>> getAnimeList({
    int limit = 10,
    DocumentSnapshot? startAfter,
    List<String>? genres,
    String? searchQuery,
    bool onlyExclusive = false,
  }) async {
    try {
      Query query = _firestore.collection('anime').limit(limit);

      // Фильтрация по жанрам
      if (genres != null && genres.isNotEmpty) {
        query = query.where('genres', arrayContainsAny: genres);
      }

      // Фильтрация по эксклюзивному контенту
      if (onlyExclusive) {
        query = query.where('isExclusive', isEqualTo: true);
      }

      // Пагинация
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final list = snapshot.docs
          .map((doc) => AnimeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Поиск по запросу (если есть)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return list.where((anime) {
          return anime.title.toLowerCase().contains(searchLower) ||
              anime.description.toLowerCase().contains(searchLower) ||
              anime.tags.any((tag) => tag.toLowerCase().contains(searchLower));
        }).toList();
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  // Получить детали аниме по ID
  Future<AnimeModel?> getAnimeDetails(String animeId) async {
    try {
      final doc = await _firestore.collection('anime').doc(animeId).get();
      if (doc.exists) {
        return AnimeModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Получить список игр с пагинацией
  Future<List<GameModel>> getGamesList({
    int limit = 10,
    DocumentSnapshot? startAfter,
    List<String>? genres,
    String? searchQuery,
    bool onlyExclusive = false,
  }) async {
    try {
      Query query = _firestore.collection('games').limit(limit);

      // Фильтрация по жанрам
      if (genres != null && genres.isNotEmpty) {
        query = query.where('genres', arrayContainsAny: genres);
      }

      // Фильтрация по эксклюзивному контенту
      if (onlyExclusive) {
        query = query.where('isExclusive', isEqualTo: true);
      }

      // Пагинация
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final list = snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Поиск по запросу (если есть)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return list.where((game) {
          return game.title.toLowerCase().contains(searchLower) ||
              game.description.toLowerCase().contains(searchLower) ||
              game.tags.any((tag) => tag.toLowerCase().contains(searchLower));
        }).toList();
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  // Получить детали игры по ID
  Future<GameModel?> getGameDetails(String gameId) async {
    try {
      final doc = await _firestore.collection('games').doc(gameId).get();
      if (doc.exists) {
        return GameModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Добавить аниме в избранное пользователя
  Future<void> addAnimeToFavorites(String userId, String animeId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([animeId])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Удалить аниме из избранного пользователя
  Future<void> removeAnimeFromFavorites(String userId, String animeId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([animeId])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Добавить оценку аниме
  Future<void> rateAnime(String animeId, double rating) async {
    try {
      // Получаем текущие данные аниме
      final animeDoc = await _firestore.collection('anime').doc(animeId).get();
      if (!animeDoc.exists) return;

      final anime = AnimeModel.fromMap(animeDoc.data()!);

      // Расчет новой средней оценки
      final newTotalRatings = anime.totalRatings + 1;
      final newRating = ((anime.rating * anime.totalRatings) + rating) / newTotalRatings;

      // Обновление данных
      await _firestore.collection('anime').doc(animeId).update({
        'rating': newRating,
        'totalRatings': newTotalRatings,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Получить список жанров аниме
  Future<List<String>> getAnimeGenres() async {
    try {
      final doc = await _firestore.collection('metadata').doc('genres').get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('anime')) {
        return List<String>.from(doc.data()!['anime']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Получить список жанров игр
  Future<List<String>> getGameGenres() async {
    try {
      final doc = await _firestore.collection('metadata').doc('genres').get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('games')) {
        return List<String>.from(doc.data()!['games']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Получить рекомендуемые аниме для пользователя
  Future<List<AnimeModel>> getRecommendedAnime(String userId, {int limit = 10}) async {
    try {
      // В реальном приложении здесь бы использовался сложный алгоритм рекомендаций
      // Для примера используем простой подход - берем аниме с высоким рейтингом
      final snapshot = await _firestore
          .collection('anime')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AnimeModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}