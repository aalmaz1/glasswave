import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class PersistenceService {
  final SharedPreferences _prefs;
  PersistenceService(this._prefs);

  static String _notesKey(String email) => 'glasswave_notes_${email.toLowerCase()}';
  static String _prefsKey(String email) => 'glasswave_prefs_${email.toLowerCase()}';
  static const String _guestNotesKey = 'glasswave_guest_notes_v1';
  static const String _guestThemeKey = 'glasswave_guest_theme';
  static const String _guestLangKey = 'glasswave_guest_lang';

  Future<void> saveNotes(String email, List<Note> notes) async {
    final raw = json.encode(notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_notesKey(email), raw);
  }

  List<Note>? getNotes(String email) {
    final raw = _prefs.getString(_notesKey(email));
    if (raw == null) return null;
    final List<dynamic> list = json.decode(raw) as List;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> savePrefs(String email, Map<String, dynamic> p) async {
    await _prefs.setString(_prefsKey(email), json.encode(p));
  }

  Map<String, dynamic> getPrefs(String email) {
    final raw = _prefs.getString(_prefsKey(email));
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  Future<void> saveLanguage(String email, String language) async {
    final prefs = getPrefs(email);
    prefs['language'] = language;
    await savePrefs(email, prefs);
  }

  String? getLanguageRaw(String email) {
    final prefs = getPrefs(email);
    return prefs['language'] as String?;
  }

  String getLanguage(String email) => getLanguageRaw(email) ?? 'ru';

  Future<void> saveGuestNotes(List<Note> notes) async {
    final raw = json.encode(notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_guestNotesKey, raw);
  }

  List<Note>? getGuestNotes() {
    final raw = _prefs.getString(_guestNotesKey);
    if (raw == null) return null;
    final List<dynamic> list = json.decode(raw) as List;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setGuestTheme(String themeId) async {
    await _prefs.setString(_guestThemeKey, themeId);
  }

  String? getGuestTheme() => _prefs.getString(_guestThemeKey);

  Future<void> setGuestLanguage(String lang) async {
    await _prefs.setString(_guestLangKey, lang);
  }

  String? getGuestLanguageRaw() => _prefs.getString(_guestLangKey);

  String getGuestLanguage() => getGuestLanguageRaw() ?? 'ru';
}
