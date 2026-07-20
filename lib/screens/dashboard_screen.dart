import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../widgets/background_orbs.dart';
import '../widgets/glass_container.dart';
import '../widgets/note_card.dart';
import '../models/note.dart';
import '../theme/app_theme_data.dart';
import 'settings_screen.dart';
import 'editor_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollY = 0;
  String _search = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollY = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final notes = ref.watch(notesProvider);
    final currentTab = ref.watch(dashboardTabProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width >= 1280) {
      crossAxisCount = 3;
    } else if (width >= 768) {
      crossAxisCount = 2;
    }

    List<Note> filteredNotes = notes.where((n) {
      bool matchesTab = false;
      if (currentTab == 0) matchesTab = !n.trashed && !n.archived;
      if (currentTab == 1) matchesTab = n.archived && !n.trashed;
      if (currentTab == 2) matchesTab = n.trashed;

      if (_search.isEmpty) return matchesTab;

      bool matchesSearch = n.title.toLowerCase().contains(_search.toLowerCase()) ||
          n.body.toLowerCase().contains(_search.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    if (sortOrder == SortOrder.created) {
      filteredNotes.sort((a, b) => b.id.compareTo(a.id));
    } else if (sortOrder == SortOrder.updated) {
      filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    final pinned = filteredNotes.where((n) => n.pinned).toList();
    final others = filteredNotes.where((n) => !n.pinned).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundOrbs(theme: theme, scrollY: _scrollY),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: width < 768 ? 50 : 60, left: 20, right: 20, bottom: 16),
                  child: _buildSearchBar(),
                ),
              ),
              if (pinned.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(tr('dash_pinned'),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white38,
                            letterSpacing: 1.2)),
                  ),
                ),
                _buildNoteGrid(pinned, crossAxisCount),
                if (others.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(tr('dash_others'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white38,
                              letterSpacing: 1.2)),
                    ),
                  ),
              ],
              _buildNoteGrid(others, crossAxisCount),
              if (filteredNotes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(currentTab),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
            ],
          ),
          _buildFab(context),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final sortActive = ref.watch(sortOrderProvider) != SortOrder.defaultValue;
    return Focus(
      onFocusChange: (focused) => setState(() {}),
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isFocused ? Colors.white.withValues(alpha: 0.40) : Colors.white.withValues(alpha: 0.20),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isFocused ? 0.55 : 0.45),
                  blurRadius: isFocused ? 40 : 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: tr('search_hint'),
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 15),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  if (_search.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: Colors.white30),
                      onPressed: () => setState(() => _search = ""),
                    ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.slidersHorizontal,
                            size: 20, color: sortActive ? Colors.amber : Colors.white60),
                        onPressed: () => _showSortSheet(),
                      ),
                      if (sortActive)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, size: 20, color: Colors.white60),
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteGrid(List<Note> items, int crossAxisCount) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) => NoteCard(note: items[index]),
        childCount: items.length,
      ),
    );
  }

  Widget _buildEmptyState(int tab) {
    String msg = tr('no_notes');
    if (tab == 1) msg = tr('empty_archive');
    if (tab == 2) msg = tr('empty_trash');
    if (_search.isNotEmpty) msg = tr('not_found');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassContainer(
          borderRadius: 14,
          blur: 16,
          child: const SizedBox(
            width: 52,
            height: 52,
            child: Icon(LucideIcons.fileText, size: 22, color: Colors.white38),
          ),
        ),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 24,
      child: _FabWithHover(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen())),
      ),
    );
  }

  Widget _buildBottomNav() {
    final currentTab = ref.watch(dashboardTabProvider);
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 340,
          child: GlassContainer(
            borderRadius: 30,
            blur: 28,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(LucideIcons.fileText, tr('notes'), currentTab == 0, 0),
                  _navItem(LucideIcons.archive, tr('archive'), currentTab == 1, 1),
                  _navItem(LucideIcons.trash2, tr('trash'), currentTab == 2, 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, int index) {
    final width = MediaQuery.of(context).size.width;
    final showLabel = width >= 768;
    return GestureDetector(
      onTap: () => ref.read(dashboardTabProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white30, size: 20),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: active ? Colors.white : Colors.white30,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
            ],
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SortBottomSheet(),
    );
  }
}

class _FabWithHover extends StatefulWidget {
  final VoidCallback onTap;
  const _FabWithHover({required this.onTap});

  @override
  State<_FabWithHover> createState() => _FabWithHoverState();
}

class _FabWithHoverState extends State<_FabWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
        transform: Matrix4.identity()..scaleByDouble(_isHovered ? 1.12 : 1.0, _isHovered ? 1.12 : 1.0, _isHovered ? 1.12 : 1.0, 1.0),
        child: GlassContainer(
          borderRadius: 16,
          color: _isHovered ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.5),
              blurRadius: _isHovered ? 60 : 40,
              offset: const Offset(0, 10),
            ),
          ],
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortOrderProvider);

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return GlassContainer(
                borderRadius: 24,
                blur: 40,
                color: const Color(0xE6121218),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.slidersHorizontal, size: 16, color: Colors.white30),
                              const SizedBox(width: 10),
                              Text(tr('sort_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 1),
                          _sortOption(ref, tr('sort_default'), tr('sort_default_sub'), SortOrder.defaultValue, LucideIcons.shuffle, current),
                          _sortOption(ref, tr('sort_created'), tr('sort_created_sub'), SortOrder.created, LucideIcons.calendarDays, current),
                          _sortOption(ref, tr('sort_updated'), tr('sort_updated_sub'), SortOrder.updated, LucideIcons.refreshCw, current),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sortOption(WidgetRef ref, String title, String sub, SortOrder value, IconData icon, SortOrder current) {
    final active = current == value;
    return InkWell(
      onTap: () {
        ref.read(sortOrderProvider.notifier).state = value;
        Navigator.pop(ref.context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active ? Colors.white10 : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? Colors.white24 : Colors.white10),
              ),
              child: Icon(icon, size: 18, color: active ? Colors.white : Colors.white30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.w500, fontSize: 15, color: active ? Colors.white : Colors.white60)),
                  Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white30)),
                ],
              ),
            ),
            if (active)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 12, color: Color(0xFF111111)),
              ),
          ],
        ),
      ),
    );
  }
}
