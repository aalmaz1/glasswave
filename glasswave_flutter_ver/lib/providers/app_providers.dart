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

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthErrors {
  static const wrongCredentials = 'auth_err_wrong_pw';
  static const emailInUse = 'auth_err_email_in_use';
  static const nameTooShort = 'auth_error_name';
  static const pwTooShort = 'auth_error_pw';
  static const sessionExpired = 'auth_err_generic';
  static const wrongPwDelete = 'auth_err_wrong_pw';
}

class AuthNotifier extends Notifier<AppUser?> {
  StreamSubscription<AppUser?>? _sub;

  @override
  AppUser? build() {
    final fbService = ref.watch(firebaseServiceProvider);
    _sub?.cancel();
    _sub = fbService.authStateChanges().listen((user) {
      state = user;
    });
    ref.onDispose(() {
      _sub?.cancel();
    });
    return fbService.currentUser;
  }

  Future<String?> login(String email, String password) async {
    final fbService = ref.read(firebaseServiceProvider);
    try {
      await fbService.login(email, password);
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

    final fbService = ref.read(firebaseServiceProvider);
    try {
      await fbService.register(email, name, password);
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
    final fbService = ref.read(firebaseServiceProvider);
    try {
      await fbService.deleteAccount(password);
      return null;
    } on FirebaseAuthException catch (_) {
      return AuthErrors.wrongPwDelete;
    } catch (_) {
      return AuthErrors.wrongPwDelete;
    }
  }

  Future<void> logout() async {
    final fbService = ref.read(firebaseServiceProvider);
    await fbService.logout();
  }
}

class AppPrefs {
  final ThemeId themeId;
  final String language;

  AppPrefs({required this.themeId, required this.language});
}

final themeProvider = NotifierProvider<ThemeNotifier, AppPrefs>(ThemeNotifier.new);

const ThemeId kDefaultTheme = ThemeId.sunset;

ThemeId _parseThemeStatic(String? raw, {ThemeId? fallback}) {
  if (raw != null) {
    for (final t in ThemeId.values) {
      if (t.name == raw) return t;
    }
  }
  return fallback ?? kDefaultTheme;
}

class ThemeNotifier extends Notifier<AppPrefs> {
  @override
  AppPrefs build() {
    final service = ref.watch(persistenceServiceProvider);
    final user = ref.watch(authProvider);
    final email = user?.email;

    ThemeId theme;
    String lang;
    bool isFirstLoad = false;

    if (email != null) {
      final raw = service.getPrefs(email);
      theme = _parseThemeStatic(raw['themeId'] as String?, fallback: kDefaultTheme);
      final savedLang = raw['language'] as String?;
      if (savedLang == null) {
        lang = 'ru';
        isFirstLoad = true;
      } else {
        lang = savedLang;
      }
    } else {
      final savedTheme = service.getGuestTheme();
      theme = _parseThemeStatic(savedTheme, fallback: kDefaultTheme);
      if (savedTheme == null) isFirstLoad = true;
      final savedLang = service.getGuestLanguageRaw();
      lang = savedLang ?? 'ru';
      if (savedLang == null) isFirstLoad = true;
    }

    final initialPrefs = AppPrefs(themeId: theme, language: lang);
    if (isFirstLoad) {
      unawaited(_persistInitial(service, email, initialPrefs));
    }
    return initialPrefs;
  }

  Future<void> _persistInitial(PersistenceService service, String? email, AppPrefs prefs) async {
    if (email != null) {
      await service.savePrefs(email, {'themeId': prefs.themeId.name, 'language': prefs.language});
    } else {
      await service.setGuestTheme(prefs.themeId.name);
      await service.setGuestLanguage(prefs.language);
    }
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
    final service = ref.read(persistenceServiceProvider);
    final user = ref.read(authProvider);
    final email = user?.email;
    if (email != null) {
      final p = {'themeId': state.themeId.name, 'language': state.language};
      await service.savePrefs(email, p);
    } else {
      await service.setGuestTheme(state.themeId.name);
      await service.setGuestLanguage(state.language);
    }
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends Notifier<List<Note>> {
  StreamSubscription<List<Note>>? _notesSub;

  @override
  List<Note> build() {
    final user = ref.watch(authProvider);
    final service = ref.watch(persistenceServiceProvider);
    final fbService = ref.watch(firebaseServiceProvider);

    _notesSub?.cancel();
    ref.onDispose(() {
      _notesSub?.cancel();
    });

    if (user != null && user.uid.isNotEmpty) {
      final cached = service.getNotes(user.email);

      _notesSub = fbService.streamNotes(user.uid).listen((remoteNotes) {
        state = remoteNotes;
        service.saveNotes(user.email, remoteNotes);
      });

      return cached ?? [];
    } else {
      return service.getGuestNotes() ?? [];
    }
  }

  Future<void> _saveNotes() async {
    final user = ref.read(authProvider);
    final service = ref.read(persistenceServiceProvider);
    if (user != null) {
      await service.saveNotes(user.email, state);
    } else {
      await service.saveGuestNotes(state);
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
    final user = ref.read(authProvider);
    final fbService = ref.read(firebaseServiceProvider);

    // Optimistic local update
    if (state.any((n) => n.id == note.id)) {
      state = state.map((n) => n.id == note.id ? note : n).toList();
    } else {
      state = [note, ...state];
    }
    await _saveNotes();

    if (user != null && user.uid.isNotEmpty) {
      final firestoreId = await fbService.writeNote(note, user.uid);
      if (note.firestoreId == null && firestoreId.isNotEmpty) {
        final updated = note.copyWith(firestoreId: firestoreId);
        state = state.map((n) => n.id == note.id ? updated : n).toList();
        await _saveNotes();
      }
    }
  }

  Future<void> clearTrash() async {
    final user = ref.read(authProvider);
    final fbService = ref.read(firebaseServiceProvider);
    final toDelete = state.where((n) => n.trashed).toList();
    state = state.where((n) => !n.trashed).toList();
    await _saveNotes();

    if (user != null && user.uid.isNotEmpty && toDelete.isNotEmpty) {
      await fbService.deleteNotes(toDelete);
    }
  }

  Future<void> updateNote(Note note) async {
    await upsert(note);
  }

  Future<void> deleteNote(int id) async {
    final user = ref.read(authProvider);
    final fbService = ref.read(firebaseServiceProvider);
    final note = state.firstWhere(
      (n) => n.id == id,
      orElse: () => Note(id: id, title: '', body: '', updatedAt: DateTime.now(), accentIdx: 0),
    );
    state = state.where((n) => n.id != id).toList();
    await NotificationService().cancelNotification(id);
    await _saveNotes();

    if (user != null && user.uid.isNotEmpty) {
      await fbService.deleteNote(note);
    }
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

final dashboardTabProvider = NotifierProvider<DashboardTabNotifier, int>(DashboardTabNotifier.new);

class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
  @override
  set state(int value) => super.state = value;
}

final sortOrderProvider = NotifierProvider<SortOrderNotifier, SortOrder>(SortOrderNotifier.new);

class SortOrderNotifier extends Notifier<SortOrder> {
  @override
  SortOrder build() => SortOrder.defaultValue;

  void setSortOrder(SortOrder order) => state = order;
  @override
  set state(SortOrder value) => super.state = value;
}


