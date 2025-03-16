import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user; // Пользователь Firebase Auth
  UserModel? _userData; // Данные пользователя из Firestore
  bool _isLoading = false;
  String? _error;

  User? get user => _user;

  UserModel? get userData => _userData;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  UserProvider() {
    _initUser();
  }

  // Инициализация текущего пользователя
  Future<void> _initUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Получаем текущего пользователя из Firebase Auth
      _user = _authService.currentUser;

      if (_user != null) {
        // Если пользователь авторизован, загружаем его данные из Firestore
        _userData = await _authService.getUserData();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Отслеживаем изменения состояния авторизации
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userData = await _authService.getUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // Регистрация пользователя
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required DateTime birthDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        birthDate: birthDate,
      );

      _user = _authService.currentUser;
      _userData = await _authService.getUserData();

      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Вход пользователя
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = _authService.currentUser;
      _userData = await _authService.getUserData();

      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Выход пользователя
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userData = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Обновление данных пользователя
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserData(data);
      _userData = await _authService.getUserData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Сброс пароля
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = _formatAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Форматирование сообщений об ошибках для пользователя
  String _formatAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Пользователь с таким email не найден';
        case 'wrong-password':
          return 'Неверный пароль';
        case 'email-already-in-use':
          return 'Этот email уже используется';
        case 'weak-password':
          return 'Пароль слишком простой. Используйте не менее 6 символов';
        case 'invalid-email':
          return 'Неверный формат email';
        case 'user-disabled':
          return 'Аккаунт отключен. Обратитесь в поддержку';
        case 'under-age':
          return 'Вам должно быть 18 лет или больше для регистрации';
        default:
          return 'Ошибка: ${e.message}';
      }
    }
    return e.toString();
  }
}
