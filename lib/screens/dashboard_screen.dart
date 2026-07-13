import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/glass_components.dart';
import '../widgets/note_card.dart';

/// Главный экран с поисковой панелью и списком заметок
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _scrollOffset = 0;

  @override
  void dispose() {
    _searchController.dispose();
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
    final state = ref.watch(notesProvider);
    final theme = state.currentTheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final crossAxisCount = _getCrossAxisCount(width);
    final gap = _getGap(width);

    final pinnedNotes = state.pinnedNotes;
    final otherNotes = state.otherNotes;

    return Stack(
      children: [
        // Фоновый градиент темы
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: theme.bgGradient),
          ),
        ),
        // Орбы с параллаксом
        ...theme.orbs.asMap().entries.map((entry) {
          final orb = entry.value;
          final index = entry.key;
          return Positioned(
            left: index == 0 ? -100 : null,
            right: index == 0 ? null : -80,
            top: 100 + _scrollOffset * 0.07 * (index == 0 ? 1 : -1),
            child: Container(
              width: orb.radius * 2,
              height: orb.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    orb.color.withOpacity(0.3),
                    orb.color.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(),
              ),
            ),
          );
        }).toList(),
        // Основной контент
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              setState(() {
                _scrollOffset = notification.metrics.pixels;
              });
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              // Пространство для поисковой панели
              SliverToBoxAdapter(
                child: SizedBox(height: 92),
              ),
              // Секция закреплённых
              if (pinnedNotes.isNotEmpty) ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'ЗАКРЕПЛЁННЫЕ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        letterSpacing: 0.09.em,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                      childAspectRatio: isMobile ? 1.3 : 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = pinnedNotes[index];
                        return NoteCard(
                          note: note,
                          theme: theme,
                          isMobile: isMobile,
                          onTap: () => _openEditor(note),
                          onPin: () => ref.read(notesProvider.notifier).togglePin(note.id),
                          onArchive: () => ref.read(notesProvider.notifier).toggleArchive(note.id),
                          onTrash: () => ref.read(notesProvider.notifier).toggleTrash(note.id),
                          onReminder: () => _showReminderSheet(note),
                        );
                      },
                      childCount: pinnedNotes.length,
                    ),
                  ),
                ),
              ],
              // Секция остальных
              if (otherNotes.isNotEmpty) ...[
                if (pinnedNotes.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'ОСТАЛЬНЫЕ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          letterSpacing: 0.09.em,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                      childAspectRatio: isMobile ? 1.3 : 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = otherNotes[index];
                        return NoteCard(
                          note: note,
                          theme: theme,
                          isMobile: isMobile,
                          onTap: () => _openEditor(note),
                          onPin: () => ref.read(notesProvider.notifier).togglePin(note.id),
                          onArchive: () => ref.read(notesProvider.notifier).toggleArchive(note.id),
                          onTrash: () => ref.read(notesProvider.notifier).toggleTrash(note.id),
                          onReminder: () => _showReminderSheet(note),
                        );
                      },
                      childCount: otherNotes.length,
                    ),
                  ),
                ),
              ],
              // Пустое состояние
              if (pinnedNotes.isEmpty && otherNotes.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_rounded,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.activeTab == NoteTab.notes
                              ? 'Нет заметок'
                              : state.activeTab == NoteTab.archive
                                  ? 'Архив пуст'
                                  : 'Корзина пуста',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Отступ снизу для навигации и FAB
              SliverToBoxAdapter(
                child: SizedBox(height: 150),
              ),
            ],
          ),
        ),
        // Поисковая панель
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.38),
                  Colors.transparent,
                ],
              ),
            ),
            child: GlassSearchBar(
              controller: _searchController,
              onChanged: (value) => ref.read(notesProvider.notifier).setSearchQuery(value),
              onClear: () {
                _searchController.clear();
                ref.read(notesProvider.notifier).setSearchQuery('');
              },
              onSort: () => _showSortSheet(),
              hasActiveSort: state.sortOption != SortOption.defaultOrder,
              onSettings: () => _openSettings(),
            ),
          ),
        ),
        // FAB
        Positioned(
          right: 20,
          bottom: isMobile ? 88 : 32,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _openEditor(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMobile ? 52 : 56,
                height: isMobile ? 52 : 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0x0FFFFFFF),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x80000000),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Нижняя навигация
        _BottomNavigation(activeTab: state.activeTab),
      ],
    );
  }

  void _openEditor(Note? note) {
    Navigator.pushNamed(
      context,
      '/editor',
      arguments: {'note': note},
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(),
    );
  }

  void _showReminderSheet(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReminderSheet(note: note),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }
}

/// Нижняя навигационная панель
class _BottomNavigation extends ConsumerWidget {
  final NoteTab activeTab;

  const _BottomNavigation({required this.activeTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final navWidth = width >= 1280 
        ? (width * 0.56).clamp(260, 420)
        : width - 32;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Container(
              width: navWidth,
              height: 56 + bottomPadding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0x0FFFFFFF),
                border: Border.all(
                  color: const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.description_rounded,
                        label: 'Заметки',
                        isActive: activeTab == NoteTab.notes,
                        onTap: () => ref.read(notesProvider.notifier).setActiveTab(NoteTab.notes),
                        isMobile: isMobile,
                      ),
                      _NavItem(
                        icon: Icons.archive_rounded,
                        label: 'Архив',
                        isActive: activeTab == NoteTab.archive,
                        onTap: () => ref.read(notesProvider.notifier).setActiveTab(NoteTab.archive),
                        isMobile: isMobile,
                      ),
                      _NavItem(
                        icon: Icons.delete_rounded,
                        label: 'Корзина',
                        isActive: activeTab == NoteTab.trash,
                        onTap: () => ref.read(notesProvider.notifier).setActiveTab(NoteTab.trash),
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isMobile;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 24,
          vertical: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              size: 22,
            ),
            if (!isMobile) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
            if (isActive) ...[
              const SizedBox(height: 6),
              Container(
                width: 18,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Лист сортировки
class _SortSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(18, 18, 24, 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сортировка',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _SortOptionTile(
                  icon: Icons.shuffle_rounded,
                  label: 'По умолчанию',
                  isActive: state.sortOption == SortOption.defaultOrder,
                  onTap: () {
                    ref.read(notesProvider.notifier).setSortOption(SortOption.defaultOrder);
                    Navigator.pop(context);
                  },
                ),
                _SortOptionTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Дата создания',
                  isActive: state.sortOption == SortOption.dateCreated,
                  onTap: () {
                    ref.read(notesProvider.notifier).setSortOption(SortOption.dateCreated);
                    Navigator.pop(context);
                  },
                ),
                _SortOptionTile(
                  icon: Icons.refresh_rounded,
                  label: 'Дата изменения',
                  isActive: state.sortOption == SortOption.dateUpdated,
                  onTap: () {
                    ref.read(notesProvider.notifier).setSortOption(SortOption.dateUpdated);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF1A1A1E),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Лист напоминаний
class _ReminderSheet extends ConsumerStatefulWidget {
  final Note note;

  const _ReminderSheet({required this.note});

  @override
  ConsumerState<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<_ReminderSheet> {
  DateTime? _selectedDateTime;

  void _setQuickReminder(Duration duration) {
    setState(() {
      _selectedDateTime = DateTime.now().add(duration);
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(18, 18, 24, 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_clock_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Напоминание',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Быстрые варианты
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickReminderChip(
                      label: 'Сегодня',
                      onTap: () => _setQuickReminder(const Duration(hours: 4)),
                      isSelected: _selectedDateTime != null &&
                          _isSameDay(_selectedDateTime!, DateTime.now()),
                    ),
                    _QuickReminderChip(
                      label: 'Завтра утром',
                      onTap: () => _setQuickReminder(const Duration(days: 1, hours: 8)),
                      isSelected: _selectedDateTime != null &&
                          _isSameDay(_selectedDateTime!, DateTime.now().add(const Duration(days: 1))),
                    ),
                    _QuickReminderChip(
                      label: 'Следующая неделя',
                      onTap: () {
                        final nextMonday = DateTime.now().add(
                          Duration(days: (8 - DateTime.now().weekday) % 7 + 7),
                        );
                        _setQuickReminder(Duration(
                          days: (8 - DateTime.now().weekday) % 7 + 7,
                          hours: 8 - DateTime.now().hour,
                        ));
                      },
                      isSelected: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Кастомный выбор
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_calendar_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDateTime != null
                              ? '${_selectedDateTime!.day}.${_selectedDateTime!.month}.${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                              : 'Выбрать дату и время',
                          style: TextStyle(
                            color: _selectedDateTime != null
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Кнопки действий
                Row(
                  children: [
                    if (widget.note.reminder != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(notesProvider.notifier).setReminder(widget.note.id, null);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Удалить',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: widget.note.reminder != null ? 1 : 2,
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedDateTime != null) {
                            ref.read(notesProvider.notifier).setReminder(
                              widget.note.id,
                              _selectedDateTime,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedDateTime != null
                                ? const Color(0xFFFFB74D)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Сохранить',
                              style: TextStyle(
                                color: _selectedDateTime != null
                                    ? const Color(0xFF1A1A1E)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickReminderChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _QuickReminderChip({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
