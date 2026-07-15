import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/app_provider.dart';
import '../models/note.dart';
import '../widgets/glass_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/note_fab.dart';
import '../widgets/note_editor.dart';
import '../widgets/reminder_modal.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/note_card.dart';
import 'settings_screen.dart';

/// Главный экран с дашбордом заметок
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Note? _editingNote;
  String? _reminderNoteId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appState, _) {
        final theme = appState.currentTheme;
        final fontSizeScale = appState.fontSize;

        if (appState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Основной контент
              SafeArea(
                child: Column(
                  children: [
                    // Поиск и кнопки
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassSearchBar(
                        value: appState.searchQuery,
                        onChanged: appState.setSearchQuery,
                        onSort: () => _showSortSheet(appState),
                        onSettings: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ),
                    // Список заметок
                    Expanded(
                      child: _buildNotesGrid(appState, fontSizeScale),
                    ),
                  ],
                ),
              ),
              // Нижняя навигация
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassBottomNav(
                  currentIndex: appState.tabIndex,
                  onTap: appState.setTabIndex,
                ),
              ),
              // FAB
              Positioned(
                right: 20,
                bottom: 90,
                child: NoteFab(onPressed: () => _openEditor(null)),
              ),
              // Редактор
              if (_editingNote != null)
                NoteEditor(
                  note: _editingNote,
                  onSave: (note) {
                    appState.upsertNote(note);
                    setState(() => _editingNote = null);
                  },
                  onClose: () => setState(() => _editingNote = null),
                ),
              // Модалка напоминания
              if (_reminderNoteId != null)
                ReminderModal(
                  currentReminder: appState.notes
                      .firstWhere((n) => n.id == _reminderNoteId)
                      .reminder,
                  onSave: (date) {
                    appState.setReminder(_reminderNoteId!, date);
                    setState(() => _reminderNoteId = null);
                  },
                  onClose: () => setState(() => _reminderNoteId = null),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesGrid(AppProvider appState, double fontSizeScale) {
    final pinnedNotes = appState.pinnedNotes;
    final regularNotes = appState.regularNotes;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Закреплённые
          if (pinnedNotes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(
                'Закреплённые',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14 * fontSizeScale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildMasonryGrid(pinnedNotes, appState, fontSizeScale),
          ],
          // Остальные
          if (regularNotes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                pinnedNotes.isEmpty ? 'Заметки' : 'Остальные',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14 * fontSizeScale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildMasonryGrid(regularNotes, appState, fontSizeScale),
          ],
          // Пустое состояние
          if (pinnedNotes.isEmpty && regularNotes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.note_add_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appState.tabIndex == 0
                          ? 'Нет заметок'
                          : appState.tabIndex == 1
                              ? 'Архив пуст'
                              : 'Корзина пуста',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16 * fontSizeScale,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.tabIndex == 0
                          ? 'Нажмите + чтобы создать'
                          : '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14 * fontSizeScale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(List<Note> notes, AppProvider appState, double fontSizeScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MasonryGridView.count(
        crossAxisCount: _getColumnCount(MediaQuery.of(context).size.width),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (ctx, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _openEditor(note),
            onPin: () => appState.togglePin(note.id),
            onArchive: () => appState.toggleArchive(note.id),
            onTrash: () => appState.trashNote(note.id),
            onReminder: () => setState(() => _reminderNoteId = note.id),
          );
        },
      ),
    );
  }

  int _getColumnCount(double width) {
    if (width > 1280) return 3;
    if (width > 768) return 2;
    return 1;
  }

  void _showSortSheet(AppProvider appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortSheet(
        selectedIndex: appState.sortIndex,
        onSelect: appState.setSortIndex,
      ),
    );
  }

  void _openEditor(Note? note) {
    setState(() => _editingNote = note);
  }
}
