import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../themes/app_themes.dart';
import '../models/note.dart';
import '../widgets/gradient_background.dart';
import '../widgets/search_panel.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/note_fab.dart';
import '../widgets/note_card.dart';
import '../widgets/note_editor.dart';

/// Главный экран (Dashboard)
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  double _scrollOffset = 0;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  int _getCrossAxisCount(double width) {
    if (width >= 1280) return 3;
    if (width >= 768) return 2;
    return 1;
  }
  
  double _getGap(double width) {
    return width >= 1280 ? 18 : 14;
  }
  
  @override
  Widget build(BuildContext context) {
    final themeId = ref.watch(themeIdProvider);
    final theme = AppTheme.all.firstWhere((t) => t.id == themeId, orElse: () => AppTheme.sunset);
    final pinnedNotes = ref.watch(pinnedNotesProvider);
    final otherNotes = ref.watch(otherNotesProvider);
    final navTab = ref.watch(navTabProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    
    return GradientBackground(
      theme: theme,
      scrollOffset: _scrollOffset,
      child: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top padding for search panel
              SliverToBoxAdapter(
                child: SizedBox(height: 92),
              ),
              
              // Pinned section
              if (pinnedNotes.isNotEmpty && navTab == NavTab.notes) ...[
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'ЗАКРЕПЛЁННЫЕ',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.09.em,
                          color: Colors.white.withOpacity(0.30),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: isMobile ? 16 : 24,
                    right: isMobile ? 16 : 24,
                    bottom: 20,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(width),
                      mainAxisSpacing: _getGap(width),
                      crossAxisSpacing: _getGap(width),
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildNoteCard(pinnedNotes[index], theme, isMobile),
                      childCount: pinnedNotes.length,
                    ),
                  ),
                ),
              ],
              
              // Other notes section
              if (otherNotes.isNotEmpty || (pinnedNotes.isEmpty && pinnedNotes.isEmpty)) ...[
                if (pinnedNotes.isNotEmpty && navTab == NavTab.notes)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'ОСТАЛЬНЫЕ',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.09.em,
                            color: Colors.white.withOpacity(0.30),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: isMobile ? 16 : 24,
                    right: isMobile ? 16 : 24,
                    bottom: 150,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(width),
                      mainAxisSpacing: _getGap(width),
                      crossAxisSpacing: _getGap(width),
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final allNotes = navTab == NavTab.notes 
                            ? otherNotes 
                            : ref.watch(filteredNotesProvider);
                        return _buildNoteCard(allNotes[index], theme, isMobile);
                      },
                      childCount: navTab == NavTab.notes 
                          ? otherNotes.length 
                          : ref.watch(filteredNotesProvider).length,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Search panel
          SearchPanel(scrollOffset: _scrollOffset),
          
          // Bottom navigation
          const BottomNavigation(),
          
          // FAB
          NoteFAB(onPressed: () => _openEditor(null)),
        ],
      ),
    );
  }
  
  Widget _buildNoteCard(Note note, AppTheme theme, bool isMobile) {
    return NoteCard(
      note: note,
      theme: theme,
      showActionsAlways: isMobile,
      onTap: () => _openEditor(note),
      onPin: () => _togglePin(note),
      onArchive: () => _toggleArchive(note),
      onTrash: () => _toggleTrash(note),
      onReminder: () => _showReminderSheet(note),
    );
  }
  
  void _openEditor(Note? note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: NoteEditor(
          note: note,
          theme: AppTheme.all.firstWhere(
            (t) => t.id == ref.read(themeIdProvider),
            orElse: () => AppTheme.sunset,
          ),
          onSave: (updatedNote) => _saveNote(updatedNote),
        ),
      ),
    );
  }
  
  void _saveNote(Note note) {
    final notifier = ref.read(notesProvider.notifier);
    final existingNote = ref.read(notesProvider).firstWhere(
      (n) => n.id == note.id,
      orElse: () => note,
    );
    
    if (existingNote.id == note.id) {
      notifier.updateNote(note);
    } else {
      notifier.addNote(note);
    }
  }
  
  void _togglePin(Note note) {
    final updated = note.copyWith(pinned: !note.pinned);
    ref.read(notesProvider.notifier).updateNote(updated);
  }
  
  void _toggleArchive(Note note) {
    final updated = note.copyWith(archived: !note.archived, pinned: false);
    ref.read(notesProvider.notifier).updateNote(updated);
  }
  
  void _toggleTrash(Note note) {
    if (note.trashed) {
      // Permanent delete
      ref.read(notesProvider.notifier).deleteNote(note.id, note.userEmail);
    } else {
      final updated = note.copyWith(trashed: true, pinned: false);
      ref.read(notesProvider.notifier).updateNote(updated);
    }
  }
  
  void _showReminderSheet(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderSheet(
        note: note,
        onSave: (reminder) {
          final updated = note.copyWith(reminder: reminder);
          ref.read(notesProvider.notifier).updateNote(updated);
        },
        onRemove: () {
          final updated = note.copyWith(reminder: null);
          ref.read(notesProvider.notifier).updateNote(updated);
        },
      ),
    );
  }
}

/// Reminder sheet widget
class ReminderSheet extends StatefulWidget {
  final Note note;
  final Function(DateTime)? onSave;
  final VoidCallback? onRemove;
  
  const ReminderSheet({
    super.key,
    required this.note,
    this.onSave,
    this.onRemove,
  });
  
  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(18, 18, 24, 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Row(
            children: [
              const Icon(Icons.calendar_clock, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Напоминание',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Quick options
          _QuickOption(
            label: 'Сегодня',
            subtitle: '20:00',
            onTap: () {
              final now = DateTime.now();
              final reminder = DateTime(now.year, now.month, now.day, 20, 0);
              widget.onSave?.call(reminder.isBefore(now) 
                  ? reminder.add(const Duration(days: 1)) 
                  : reminder);
              Navigator.pop(context);
            },
          ),
          _QuickOption(
            label: 'Завтра утром',
            subtitle: '08:00',
            onTap: () {
              final tomorrow = DateTime.now().add(const Duration(days: 1));
              widget.onSave?.call(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0));
              Navigator.pop(context);
            },
          ),
          _QuickOption(
            label: 'Следующая неделя',
            subtitle: 'Понедельник 08:00',
            onTap: () {
              final now = DateTime.now();
              final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7 + 7));
              widget.onSave?.call(DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 8, 0));
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Custom picker button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                
                if (date != null && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
                  if (time != null && context.mounted) {
                    final reminder = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                    widget.onSave?.call(reminder);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.edit_calendar, color: Colors.amber),
              label: const Text('Выбрать дату', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Remove button if reminder exists
          if (widget.note.reminder != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  widget.onRemove?.call();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Удалить напоминание', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  
  const _QuickOption({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.access_time, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }
}
