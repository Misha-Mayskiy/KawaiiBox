import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;
  final DateTime birthDate;
  final DateTime createdAt;
  final List<String> favorites;
  final List<String> watchHistory;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.birthDate,
    required this.createdAt,
    this.favorites = const [],
    this.watchHistory = const [],
  });

  // Проверка возраста - пользователю должно быть 18+
  bool get isAdult {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final age = difference.inDays ~/ 365;
    return age >= 18;
  }

  // Преобразование из Map (данные из Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      photoUrl: map['photoUrl'],
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      favorites: List<String>.from(map['favorites'] ?? []),
      watchHistory: List<String>.from(map['watchHistory'] ?? []),
    );
  }

  // Преобразование в Map (для сохранения в Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'birthDate': Timestamp.fromDate(birthDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'favorites': favorites,
      'watchHistory': watchHistory,
    };
  }
}