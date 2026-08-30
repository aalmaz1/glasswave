import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/app_user.dart';
import '../services/persistence_service.dart';
import '../theme/app_theme_data.dart';

enum SortOrder { defaultValue, created, updated }

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PersistenceService(prefs);
});

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  final service = ref.watch(persistenceServiceProvider);
  return AuthNotifier(service);
});

class AuthErrors {
  static const wrongCredentials = 'auth_err_wrong_pw';
  static const emailInUse = 'auth_err_email_in_use';
  static const nameTooShort = 'auth_error_name';
  static const pwTooShort = 'auth_error_pw';
  static const sessionExpired = 'auth_err_generic';
  static const wrongPwDelete = 'auth_err_wrong_pw';
}

class AuthNotifier extends StateNotifier<AppUser?> {
  final PersistenceService _service;

  AuthNotifier(this._service) : super(null) {
    _loadUser();
  }

  void _loadUser() {
    state = _service.getMe();
  }

  Future<String?> login(String email, String password) async {
    email = email.toLowerCase().trim();
    final ok = _service.verifyPassword(email, password);
    if (!ok) return AuthErrors.wrongCredentials;
    final users = await _service.getUsers();
    final data = users[email];
    final name = (data is Map && data['name'] is String) ? (data['name'] as String) : email;
    final appUser = AppUser(email: email, name: name);
    state = appUser;
    await _service.setMe(appUser);
    return null;
  }

  Future<String?> register(String email, String name, String password) async {
    email = email.toLowerCase().trim();
    final users = await _service.getUsers();
    if (users.containsKey(email)) return AuthErrors.emailInUse;
    if (name.trim().length < 2) return AuthErrors.nameTooShort;
    if (password.length < 6) return AuthErrors.pwTooShort;

    await _service.saveUser(email, name.trim(), password);
    final appUser = AppUser(email: email, name: name.trim());
    state = appUser;
    await _service.setMe(appUser);
    return null;
  }

  Future<String?> deleteAccount(String password) async {
    final user = state;
    if (user == null) return AuthErrors.sessionExpired;
    if (!_service.verifyPassword(user.email, password)) {
      return AuthErrors.wrongPwDelete;
    }
    await _service.deleteUser(user.email);
    await _service.setMe(null);
    state = null;
    return null;
  }

  Future<void> logout() async {
    state = null;
    await _service.setMe(null);
  }
}

class AppPrefs {
  final ThemeId themeId;
  final String language;

  AppPrefs({required this.themeId, required this.language});
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppPrefs>((ref) {
  final service = ref.watch(persistenceServiceProvider);
  final user = ref.watch(authProvider);
  final email = user?.email;
  String? preloadedLang;
  String? preloadedTheme;
  if (email != null) {
    final prefs = service.getPrefs(email);
    preloadedLang = prefs['language'] as String?;
    preloadedTheme = prefs['themeId'] as String?;
  } else {
    preloadedLang = service.getGuestLanguageRaw();
    preloadedTheme = service.getGuestTheme();
  }
  final initialTheme = _parseThemeStatic(preloadedTheme, fallback: null);
  return ThemeNotifier(service, email, initialTheme, preloadedLang ?? 'ru');
});

const ThemeId kDefaultTheme = ThemeId.sunset;

ThemeId _parseThemeStatic(String? raw, {ThemeId? fallback}) {
  if (raw != null) {
    for (final t in ThemeId.values) {
      if (t.name == raw) return t;
    }
  }
  return fallback ?? kDefaultTheme;
}

class ThemeNotifier extends StateNotifier<AppPrefs> {
  final PersistenceService _service;
  final String? _email;

  ThemeNotifier(this._service, this._email, ThemeId initialTheme, String initialLang)
      : super(AppPrefs(themeId: initialTheme, language: initialLang)) {
    _loadPrefs();
  }

  void _loadPrefs() {
    ThemeId theme;
    String lang;
    bool isFirstLoad = false;
    if (_email != null) {
      final raw = _service.getPrefs(_email!);
      theme = _parseTheme(raw['themeId'] as String?, fallback: kDefaultTheme);
      final savedLang = raw['language'] as String?;
      if (savedLang == null) {
        lang = state.language;
        isFirstLoad = true;
      } else {
        lang = savedLang;
      }
    } else {
      final savedTheme = _service.getGuestTheme();
      theme = _parseTheme(savedTheme, fallback: kDefaultTheme);
      if (savedTheme == null) isFirstLoad = true;
      final savedLang = _service.getGuestLanguageRaw();
      lang = savedLang ?? state.language;
      if (savedLang == null) isFirstLoad = true;
    }
    state = AppPrefs(themeId: theme, language: lang);
    if (isFirstLoad) unawaited(_persistInitial());
  }

  Future<void> _persistInitial() async {
    if (_email != null) {
      await _service.savePrefs(_email!, {'themeId': state.themeId.name, 'language': state.language});
    } else {
      await _service.setGuestTheme(state.themeId.name);
      await _service.setGuestLanguage(state.language);
    }
  }

  ThemeId _parseTheme(String? raw, {ThemeId? fallback}) {
    if (raw != null) {
      for (final t in ThemeId.values) {
        if (t.name == raw) return t;
      }
    }
    return fallback ?? kDefaultTheme;
  }

  void setTheme(ThemeId id) {
    state = AppPrefs(themeId: id, language: state.language);
    _persist();
  }

  void setLanguage(String lang) {
    state = AppPrefs(themeId: state.themeId, language: lang);
    _persist();
  }

  Future<void> _persist() async {
    if (_email != null) {
      final p = {'themeId': state.themeId.name, 'language': state.language};
      await _service.savePrefs(_email!, p);
    } else {
      await _service.setGuestTheme(state.themeId.name);
      await _service.setGuestLanguage(state.language);
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final user = ref.watch(authProvider);
  final service = ref.watch(persistenceServiceProvider);
  return NotesNotifier(service, user?.email);
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final PersistenceService _service;
  final String? _email;

  NotesNotifier(this._service, this._email) : super([]) {
    _loadNotes();
  }

  void _loadNotes() {
    if (_email != null) {
      state = _service.getNotes(_email!) ?? [];
    } else {
      state = _service.getGuestNotes() ?? [];
    }
  }

  Future<void> _saveNotes() async {
    if (_email != null) {
      await _service.saveNotes(_email!, state);
    } else {
      await _service.saveGuestNotes(state);
    }
  }

  Note? findById(int id) {
    for (final n in state) {
      if (n.id == id) return n;
    }
    return null;
  }

  Future<void> addNote(Note note) async {
    state = [note, ...state];
    await _saveNotes();
  }

  Future<void> upsert(Note note) async {
    if (state.any((n) => n.id == note.id)) {
      state = state.map((n) => n.id == note.id ? note : n).toList();
    } else {
      state = [note, ...state];
    }
    await _saveNotes();
  }

  Future<void> clearTrash() async {
    state = state.where((n) => !n.trashed).toList();
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    state = state.map((n) => n.id == note.id ? note : n).toList();
    await _saveNotes();
  }

  Future<void> deleteNote(int id) async {
    state = state.where((n) => n.id != id).toList();
    await _saveNotes();
  }

  Future<void> togglePin(int id) async {
    final note = state.firstWhere((n) => n.id == id);
    await updateNote(note.copyWith(pinned: !note.pinned));
  }

  Future<void> toggleArchive(int id) async {
    final note = state.firstWhere((n) => n.id == id);
    await updateNote(note.copyWith(archived: !note.archived, trashed: false));
  }

  Future<void> toggleTrash(int id) async {
    final note = state.firstWhere((n) => n.id == id);
    await updateNote(note.copyWith(trashed: !note.trashed, archived: false));
  }

  Future<void> setReminder(int id, DateTime? reminder) async {
    final note = state.firstWhere((n) => n.id == id);
    await updateNote(
      note.copyWith(reminder: reminder, clearReminder: reminder == null),
    );
  }

  void clearNotes() { state = []; }
}

final dashboardTabProvider = StateProvider<int>((ref) => 0);
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.defaultValue);
