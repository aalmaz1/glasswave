import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../themes/app_theme.dart';
import 'note_card.dart';

enum SortOption {
  defaultOrder,
  dateCreated,
  dateUpdated,
}

enum NoteTab {
  notes,
  archive,
  trash,
}

class NotesState {
  final List<Note> notes;
  final String searchQuery;
  final SortOption sortOption;
  final NoteTab activeTab;
  final int themeId;
  final double fontSizeScale;
  final String? currentUserEmail;

  NotesState({
    this.notes = const [],
    this.searchQuery = '',
    this.sortOption = SortOption.defaultOrder,
    this.activeTab = NoteTab.notes,
    this.themeId = 0,
    this.fontSizeScale = 1.0,
    this.currentUserEmail,
  });

  NotesState copyWith({
    List<Note>? notes,
    String? searchQuery,
    SortOption? sortOption,
    NoteTab? activeTab,
    int? themeId,
    double? fontSizeScale,
    String? currentUserEmail,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      activeTab: activeTab ?? this.activeTab,
      themeId: themeId ?? this.themeId,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      currentUserEmail: currentUserEmail ?? this.currentUserEmail,
    );
  }

  /// Получить отфильтрованные и отсортированные заметки
  List<Note> get filteredNotes {
    var result = notes.where((note) {
      // Фильтрация по табам
      switch (activeTab) {
        case NoteTab.notes:
          if (note.archived || note.trashed) return false;
          break;
        case NoteTab.archive:
          if (!note.archived || note.trashed) return false;
          break;
        case NoteTab.trash:
          if (!note.trashed) return false;
          break;
      }

      // Поиск по тексту
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!note.title.toLowerCase().contains(query) &&
            !note.body.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Сортировка
    switch (sortOption) {
      case SortOption.defaultOrder:
        // Закреплённые сначала, потом по id desc
        result.sort((a, b) {
          if (a.pinned && !b.pinned) return -1;
          if (!a.pinned && b.pinned) return 1;
          return b.id.compareTo(a.id);
        });
        break;
      case SortOption.dateCreated:
        result.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.dateUpdated:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return result;
  }

  /// Получить закреплённые заметки
  List<Note> get pinnedNotes => 
      filteredNotes.where((n) => n.pinned).toList();

  /// Получить остальные заметки
  List<Note> get otherNotes => 
      filteredNotes.where((n) => !n.pinned).toList();

  AppTheme get currentTheme => AppTheme.getById(themeId);
}

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier();
});

class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier() : super(NotesState());

  void setNotes(List<Note> notes) {
    state = state.copyWith(notes: notes);
  }

  void addNote(Note note) {
    state = state.copyWith(notes: [...state.notes, note]);
  }

  void updateNote(Note note) {
    state = state.copyWith(
      notes: state.notes.map((n) => n.id == note.id ? note : n).toList(),
    );
  }

  void deleteNote(int noteId) {
    state = state.copyWith(
      notes: state.notes.where((n) => n.id != noteId).toList(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setActiveTab(NoteTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setThemeId(int themeId) {
    state = state.copyWith(themeId: themeId);
  }

  void setFontSizeScale(double scale) {
    state = state.copyWith(fontSizeScale: scale);
  }

  void setCurrentUserEmail(String? email) {
    state = state.copyWith(currentUserEmail: email);
  }

  void togglePin(int noteId) {
    state = state.copyWith(
      notes: state.notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(pinned: !n.pinned);
        }
        return n;
      }).toList(),
    );
  }

  void toggleArchive(int noteId) {
    state = state.copyWith(
      notes: state.notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(
            archived: !n.archived,
            pinned: n.archived ? n.pinned : false,
          );
        }
        return n;
      }).toList(),
    );
  }

  void toggleTrash(int noteId) {
    state = state.copyWith(
      notes: state.notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(
            trashed: !n.trashed,
            archived: n.trashed ? n.archived : false,
            pinned: n.trashed ? n.pinned : false,
          );
        }
        return n;
      }).toList(),
    );
  }

  void setReminder(int noteId, DateTime? reminder) {
    state = state.copyWith(
      notes: state.notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(reminder: reminder);
        }
        return n;
      }).toList(),
    );
  }
}
