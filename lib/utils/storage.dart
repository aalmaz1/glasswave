import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/note.dart';

/// Утилиты для работы с локальным хранилищем (SharedPreferences)
class Storage {
  static const String _usersKey = 'noova_users';
  static const String _currentUserKey = 'noova_current_user';
  static const String _themeKey = 'noova_theme';
  static const String _fontSizeKey = 'noova_font_size';
  static const String _notesPrefix = 'noova_notes_';

  /// Получить всех пользователей
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((u) => User.fromJson(jsonDecode(u))).toList();
  }

  /// Сохранить всех пользователей
  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  /// Получить текущего пользователя
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  /// Установить текущего пользователя
  static Future<void> setCurrentUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }
  }

  /// Получить заметки пользователя по email
  static Future<List<Note>> getNotes(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('$_notesPrefix$email') ?? [];
    return notesJson.map((n) => Note.fromJson(jsonDecode(n))).toList();
  }

  /// Сохранить заметки пользователя
  static Future<void> saveNotes(String email, List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('$_notesPrefix$email', notesJson);
  }

  /// Получить выбранную тему
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'sunset';
  }

  /// Сохранить выбранную тему
  static Future<void> saveTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  /// Получить размер шрифта (0.875, 1.0, 1.125)
  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 1.0;
  }

  /// Сохранить размер шрифта
  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  /// Простой хеш пароля (base64 для демонстрации)
  static String hashPassword(String password) => base64Encode(utf8.encode(password));

  /// Проверка пароля
  static bool verifyPassword(String password, String hash) =>
      hashPassword(password) == hash;
}
