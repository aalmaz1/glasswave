import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../models/auth_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Providers для управления состоянием

// Текущий пользователь
final currentUserProvider = StateProvider<AuthUser?>((ref) => null);

// Все заметки текущего пользователя
final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);
  
  String get _boxName {
    // Will be set when user logs in
    return 'noova_notes_default';
  }
  
  void setUserEmail(String email) {
    state = [];
    loadNotes(email);
  }
  
  Future<void> loadNotes(String email) async {
    final boxName = 'noova_notes_$email';
    final box = await Hive.openBox<Map>(boxName);
    final notes = box.values.map((e) => Note.fromJson(Map<String, dynamic>.from(e))).toList();
    state = notes.cast<Note>();
  }
  
  Future<void> addNote(Note note) async {
    final boxName = 'noova_notes_${note.userEmail}';
    final box = await Hive.openBox<Map>(boxName);
    await box.put(note.id, note.toJson());
    state = [...state, note];
  }
  
  Future<void> updateNote(Note note) async {
    final boxName = 'noova_notes_${note.userEmail}';
    final box = await Hive.openBox<Map>(boxName);
    await box.put(note.id, note.toJson());
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }
  
  Future<void> deleteNote(int id, String email) async {
    final boxName = 'noova_notes_$email';
    final box = await Hive.openBox<Map>(boxName);
    await box.delete(id);
    state = state.where((n) => n.id != id).toList();
  }
  
  void reset() {
    state = [];
  }
}

// Фильтр поиска
final searchQueryProvider = StateProvider<String>((ref) => '');

// Активная сортировка
enum SortOption {
  defaultOrder,      // По умолчанию (порядок добавления)
  dateCreated,       // Дата создания (id desc)
  dateModified,      // Дата изменения (updatedAt desc)
}

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.defaultOrder);

// Активная вкладка навигации
enum NavTab {
  notes,
  archive,
  trash,
}

final navTabProvider = StateProvider<NavTab>((ref) => NavTab.notes);

// Отфильтрованные и отсортированные заметки
final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sortOption = ref.watch(sortOptionProvider);
  final navTab = ref.watch(navTabProvider);
  
  // Filter by tab
  List<Note> filtered = notes.where((note) {
    if (navTab == NavTab.archive) return note.archived && !note.trashed;
    if (navTab == NavTab.trash) return note.trashed;
    return !note.archived && !note.trashed;
  }).toList();
  
  // Filter by search query
  if (query.isNotEmpty) {
    filtered = filtered.where((note) {
      return note.title.toLowerCase().contains(query) ||
             note.body.toLowerCase().contains(query);
    }).toList();
  }
  
  // Sort
  switch (sortOption) {
    case SortOption.dateCreated:
      filtered.sort((a, b) => b.id.compareTo(a.id));
      break;
    case SortOption.dateModified:
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case SortOption.defaultOrder:
      // Keep original order (pinned first, then by id)
      break;
  }
  
  return filtered;
});

// Закреплённые заметки
final pinnedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(filteredNotesProvider);
  return notes.where((n) => n.pinned).toList();
});

// Остальные заметки
final otherNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(filteredNotesProvider);
  return notes.where((n) => !n.pinned).toList();
});

// Preferences provider
final themeIdProvider = StateProvider<String>((ref) => 'sunset');
final fontSizeProvider = StateProvider<double>((ref) => 1.0);
