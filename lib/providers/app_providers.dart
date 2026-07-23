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

class AuthNotifier extends StateNotifier<AppUser?> {
  final PersistenceService _service;

  AuthNotifier(this._service) : super(null) {
    _loadUser();
  }

  void _loadUser() {
    state = _service.getMe();
  }

  Future<String?> login(String email, String password) async {
    final users = await _service.getUsers();
    final userData = users[email.toLowerCase()];
    if (userData == null) return "Пользователь не найден";
    if (userData['pw'] != password) return "Неверный пароль";

    final appUser = AppUser(email: email.toLowerCase(), name: userData['name']);
    state = appUser;
    await _service.setMe(appUser);
    return null;
  }

  Future<String?> register(String email, String name, String password) async {
    final users = await _service.getUsers();
    if (users.containsKey(email.toLowerCase())) return "Этот email уже используется";

    await _service.saveUser(email.toLowerCase(), name, password);
    final appUser = AppUser(email: email.toLowerCase(), name: name);
    state = appUser;
    await _service.setMe(appUser);
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
  return ThemeNotifier(service, user?.email);
});

class ThemeNotifier extends StateNotifier<AppPrefs> {
  final PersistenceService _service;
  final String? _email;

  ThemeNotifier(this._service, this._email) : super(AppPrefs(themeId: ThemeId.sunset, language: 'ru')) {
    if (_email != null) {
      _loadPrefs();
    }
  }

  Future<void> _loadPrefs() async {
    if (_email == null) return;
    final raw = _service.getPrefs(_email);
    if (raw.isEmpty) return;

    final themeIdStr = raw['themeId'] as String?;
    final themeId = themeIdStr != null && ThemeId.values.any((t) => t.name == themeIdStr)
        ? ThemeId.values.firstWhere((t) => t.name == themeIdStr)
        : ThemeId.sunset;
    final language = raw['language'] ?? 'ru';

    state = AppPrefs(themeId: themeId, language: language);
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
    if (_email == null) return;
    final p = {'themeId': state.themeId.name, 'language': state.language};
    await _service.savePrefs(_email, p);
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
    if (_email != null) {
      _loadNotes();
    }
  }

  void _loadNotes() {
    if (_email == null) return;
    state = _service.getNotes(_email) ?? [];
  }

  Future<void> _saveNotes() async {
    if (_email == null) return;
    await _service.saveNotes(_email, state);
  }

  Future<void> addNote(Note note) async {
    state = [...state, note];
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
    await updateNote(note.copyWith(reminder: reminder));
  }

  void clearNotes() {
    state = [];
  }
}

final dashboardTabProvider = StateProvider<int>((ref) => 0);
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.defaultValue);
