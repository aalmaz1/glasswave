import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/app_user.dart';

/// Application-wide salt for password hashing. This is NOT a secret (anything
/// stored client-side never is), but it prevents the raw password from being
/// readable in SharedPreferences backups and casual device inspection.
const _kPwSalt = 'glasswave::v1::local-only::salt';

String _hashPassword(String password) {
  final bytes = utf8.encode('$_kPwSalt::$password');
  return sha256.convert(bytes).toString();
}

class PersistenceService {
  final SharedPreferences _prefs;
  PersistenceService(this._prefs);

  static const String _usersKey = 'glasswave_users_v2';
  static const String _meKey = 'glasswave_me_v2';
  static String _notesKey(String email) => 'glasswave_notes_${email.toLowerCase()}';
  static String _prefsKey(String email) => 'glasswave_prefs_${email.toLowerCase()}';
  static const String _guestThemeKey = 'glasswave_guest_theme';
  static const String _guestLangKey = 'glasswave_guest_lang';

  // ── Auth ──────────────────────────────────────────────────────────
  Future<void> deleteUser(String email) async {
    final users = await getUsers();
    users.remove(email.toLowerCase());
    await _prefs.setString(_usersKey, json.encode(users));
    await _prefs.remove(_notesKey(email));
    await _prefs.remove(_prefsKey(email));
  }

  Future<void> saveUser(String email, String name, String password) async {
    final users = await getUsers();
    users[email.toLowerCase()] = {
      'name': name,
      'pwHash': _hashPassword(password),
    };
    await _prefs.setString(_usersKey, json.encode(users));
  }

  bool verifyPassword(String email, String password) {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return false;
    final users = Map<String, dynamic>.from(json.decode(raw) as Map);
    final record = users[email.toLowerCase()];
    if (record is! Map) return false;
    // Legacy migration: accept plaintext "pw" from old installs once, then upgrade.
    final stored = record['pwHash'] ?? record['pw'];
    if (stored == null) return false;
    final inputHash = _hashPassword(password);
    if (stored == inputHash) return true;
    if (stored == password) {
      // Legacy plaintext match — transparently upgrade record to hashed.
      record['pwHash'] = inputHash;
      record.remove('pw');
      _prefs.setString(_usersKey, json.encode(users));
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getUsers() async {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw) as Map);
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
    return AppUser.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  // ── Notes ─────────────────────────────────────────────────────────
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

  // ── User Prefs ────────────────────────────────────────────────────
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

  String getLanguage(String email) {
    return getLanguageRaw(email) ?? 'ru';
  }

  // ── Guest notes (not logged in) ─────────────────────────────────
  static const String _guestNotesKey = 'glasswave_guest_notes_v1';

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

  // ── Guest prefs (not logged in) ──────────────────────────────────
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
