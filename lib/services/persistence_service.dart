import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/app_user.dart';

class PersistenceService {
  final SharedPreferences _prefs;
  PersistenceService(this._prefs);

  static const String _usersKey = 'noova_users';
  static const String _meKey = 'noova_me';
  static String _notesKey(String email) => 'noova_notes_$email';
  static String _prefsKey(String email) => 'noova_prefs_$email';

  // Auth
  Future<void> saveUser(String email, String name, String password) async {
    final users = await getUsers();
    users[email.toLowerCase()] = {'name': name, 'pw': password};
    await _prefs.setString(_usersKey, json.encode(users));
  }

  Future<Map<String, dynamic>> getUsers() async {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw));
  }

  Future<void> setMe(AppUser? user) async {
    if (user == null) {
      await _prefs.remove(_meKey);
    } else {
      await _prefs.setString(_meKey, json.encode(user.toJson()));
    }
  }

  AppUser? getMe() {
    final raw = _prefs.getString(_meKey);
    if (raw == null) return null;
    return AppUser.fromJson(json.decode(raw));
  }

  // Notes
  Future<void> saveNotes(String email, List<Note> notes) async {
    final raw = json.encode(notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_notesKey(email), raw);
  }

  List<Note>? getNotes(String email) {
    final raw = _prefs.getString(_notesKey(email));
    if (raw == null) return null;
    final List<dynamic> list = json.decode(raw);
    return list.map((e) => Note.fromJson(e)).toList();
  }

  // User Prefs
  Future<void> savePrefs(String email, Map<String, dynamic> p) async {
    await _prefs.setString(_prefsKey(email), json.encode(p));
  }

  Map<String, dynamic> getPrefs(String email) {
    final raw = _prefs.getString(_prefsKey(email));
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw));
  }

  Future<void> saveLanguage(String email, String language) async {
    final prefs = getPrefs(email);
    prefs['language'] = language;
    await savePrefs(email, prefs);
  }

  String getLanguage(String email) {
    final prefs = getPrefs(email);
    return prefs['language'] ?? 'ru';
  }
}
