import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Поток для отслеживания изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Регистрация с email и паролем
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required DateTime birthDate,
  }) async {
    try {
      if (DateTime.now().difference(birthDate).inDays ~/ 365 < 18) {
        throw FirebaseAuthException(
          code: 'under-age',
          message: 'Вам должно быть 18 лет или больше для регистрации',
        );
      }

      // Создание пользователя в Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Создание профиля пользователя в Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set(
            UserModel(
              uid: credential.user!.uid,
              email: email,
              username: username,
              birthDate: birthDate,
              createdAt: DateTime.now(),
            ).toMap(),
          );

      // Обновление отображаемого имени в Firebase Auth
      await credential.user!.updateDisplayName(username);

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Вход с email и паролем
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Получить данные пользователя из Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (currentUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Обновить данные пользователя
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser!.uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Сбросить пароль
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
