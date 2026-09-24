import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/app_user.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/persistence_service.dart';
import '../theme/app_theme_data.dart';

enum SortOrder { defaultValue, created, updated }

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PersistenceService(prefs);
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  final fbService = ref.watch(firebaseServiceProvider);
  return AuthNotifier(fbService);
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
  final FirebaseService _fbService;
  StreamSubscription<AppUser?>? _sub;

  AuthNotifier(this._fbService) : super(_fbService.currentUser) {
    _sub = _fbService.authStateChanges().listen((user) {
      state = user;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<String?> login(String email, String password) async {
    try {
      await _fbService.login(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return AuthErrors.wrongCredentials;
        case 'invalid-email':
          return 'auth_err_invalid_email';
        case 'user-disabled':
          return 'auth_err_not_allowed';
        case 'too-many-requests':
          return 'auth_err_too_many';
        default:
          return AuthErrors.wrongCredentials;
      }
    } catch (e) {
      return AuthErrors.wrongCredentials;
    }
  }

  Future<String?> register(String email, String name, String password) async {
    if (name.trim().length < 2) return AuthErrors.nameTooShort;
    if (password.length < 6) return AuthErrors.pwTooShort;

    try {
      await _fbService.register(email, name, password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return AuthErrors.emailInUse;
        case 'weak-password':
          return AuthErrors.pwTooShort;
        case 'invalid-email':
          return 'auth_err_invalid_email';
        default:
          return AuthErrors.emailInUse;
      }
    } catch (_) {
      return AuthErrors.emailInUse;
    }
  }

  Future<String?> deleteAccount(String password) async {
    try {
      await _fbService.deleteAccount(password);
      return null;
    } on FirebaseAuthException catch (_) {
      return AuthErrors.wrongPwDelete;
    } catch (_) {
      return AuthErrors.wrongPwDelete;
    }
  }

  Future<void> logout() async {
    await _fbService.logout();
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
      final raw = _service.getPrefs(_email);
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
      await _service.savePrefs(_email, {'themeId': state.themeId.name, 'language': state.language});
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
      await _service.savePrefs(_email, p);
    } else {
      await _service.setGuestTheme(state.themeId.name);
      await _service.setGuestLanguage(state.language);
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final user = ref.watch(authProvider);
  final service = ref.watch(persistenceServiceProvider);
  final fbService = ref.watch(firebaseServiceProvider);
  return NotesNotifier(service, fbService, user);
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final PersistenceService _service;
  final FirebaseService _fbService;
  final AppUser? _user;
  StreamSubscription<List<Note>>? _notesSub;

  NotesNotifier(this._service, this._fbService, this._user) : super([]) {
    _initNotes();
  }

  void _initNotes() {
    final user = _user;
    if (user != null && user.uid.isNotEmpty) {
      final cached = _service.getNotes(user.email);
      if (cached != null) state = cached;

      _notesSub = _fbService.streamNotes(user.uid).listen((remoteNotes) {
        state = remoteNotes;
        _service.saveNotes(user.email, remoteNotes);
      });
    } else {
      state = _service.getGuestNotes() ?? [];
    }
  }

  @override
  void dispose() {
    _notesSub?.cancel();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final user = _user;
    if (user != null) {
      await _service.saveNotes(user.email, state);
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
    await upsert(note);
  }

  Future<void> upsert(Note note) async {
    final user = _user;
    if (user != null && user.uid.isNotEmpty) {
      final firestoreId = await _fbService.writeNote(note, user.uid);
      final updated = note.copyWith(firestoreId: firestoreId);
      if (state.any((n) => n.id == note.id)) {
        state = state.map((n) => n.id == note.id ? updated : n).toList();
      } else {
        state = [updated, ...state];
      }
    } else {
      if (state.any((n) => n.id == note.id)) {
        state = state.map((n) => n.id == note.id ? note : n).toList();
      } else {
        state = [note, ...state];
      }
    }
    await _saveNotes();
  }

  Future<void> clearTrash() async {
    final user = _user;
    final toDelete = state.where((n) => n.trashed).toList();
    state = state.where((n) => !n.trashed).toList();
    if (user != null && user.uid.isNotEmpty) {
      for (final note in toDelete) {
        await _fbService.deleteNote(note);
      }
    }
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    await upsert(note);
  }

  Future<void> deleteNote(int id) async {
    final note = state.firstWhere((n) => n.id == id, orElse: () => Note(id: id, title: '', body: '', updatedAt: DateTime.now(), accentIdx: 0));
    state = state.where((n) => n.id != id).toList();
    await NotificationService().cancelNotification(id);
    final user = _user;
    if (user != null && user.uid.isNotEmpty) {
      await _fbService.deleteNote(note);
    }
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
    final updated = note.copyWith(reminder: reminder, clearReminder: reminder == null);
    await updateNote(updated);

    if (reminder != null) {
      await NotificationService().scheduleNotification(
        id: updated.id,
        title: updated.title,
        body: updated.body,
        scheduledDate: reminder,
      );
    } else {
      await NotificationService().cancelNotification(updated.id);
    }
  }

  void clearNotes() {
    state = [];
  }
}

final dashboardTabProvider = StateProvider<int>((ref) => 0);
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.defaultValue);
