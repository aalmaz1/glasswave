import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../widgets/background_orbs.dart';
import '../widgets/glass_container.dart';
import '../widgets/note_card.dart';
import '../widgets/confirm_dialog.dart';
import '../models/note.dart';
import '../services/welcome_notes.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';
import 'settings_screen.dart';
import 'editor_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final ValueNotifier<double> _scrollY = ValueNotifier<double>(0);

  Timer? _nowTicker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _scrollY.value = _scrollController.offset;
    });
    _searchController.addListener(() => setState(() {}));
    _searchFocus.addListener(() => setState(() {}));
    _nowTicker = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nowTicker?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollY.dispose();
    super.dispose();
  }

  double get _contentGap {
    final width = MediaQuery.of(context).size.width;
    return width < 768 ? 14 : 18;
  }

  double get _contentPad {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 24;
    if (width < 1280) return 36;
    return 52;
  }

  double get _headerPad {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 16;
    if (width < 1280) return 28;
    return 44;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final storedNotes = ref.watch(notesProvider);
    final user = ref.watch(authProvider);
    final notes =
        user == null && storedNotes.isEmpty ? buildWelcomeNotes() : storedNotes;
    final currentTab = ref.watch(dashboardTabProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    int crossAxisCount = 1;
    if (width >= 1280) {
      crossAxisCount = 3;
    } else if (width >= 768) {
      crossAxisCount = 2;
    }

    final search = _searchController.text;
    List<Note> filteredNotes = notes.where((n) {
      bool matchesTab = false;
      if (currentTab == 0) matchesTab = !n.trashed && !n.archived;
      if (currentTab == 1) matchesTab = n.archived && !n.trashed;
      if (currentTab == 2) matchesTab = n.trashed;

      if (search.isEmpty) return matchesTab;

      final q = search.toLowerCase();
      final matchesSearch = n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q);
      return matchesTab && matchesSearch;
    }).toList();

    if (sortOrder == SortOrder.created) {
      filteredNotes.sort((a, b) => b.id.compareTo(a.id));
    } else if (sortOrder == SortOrder.updated) {
      filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    final pinned = filteredNotes.where((n) => n.pinned).toList();
    final others = filteredNotes.where((n) => !n.pinned).toList();

    final maxContentWidth = isMobile ? double.infinity : (width < 1280 ? 920.0 : 1220.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundOrbs(theme: theme, scrollY: _scrollY),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Stack(
                children: [
                  CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 92 + safeTop,
                  left: _contentPad,
                  right: _contentPad,
                  bottom: 150 + safeBottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (currentTab == 2 && filteredNotes.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EmptyTrashButton(
                            onTap: () async {
                              final result = await showGlassConfirm(
                                context,
                                title: tr('empty_trash_confirm_title'),
                                body: tr('empty_trash_confirm_body'),
                                confirmLabel: tr('empty_trash_btn'),
                                cancelLabel: tr('cancel'),
                              );
                              if (result == GlassConfirmChoice.confirm && mounted) {
                                ref.read(notesProvider.notifier).clearTrash();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                    if (filteredNotes.isEmpty)
                      _EmptyState(
                        tab: currentTab,
                        showingSearch: search.isNotEmpty,
                        onCreate: () => openEditorOverlay(context),
                      )
                    else ...[
                      if (pinned.isNotEmpty) ...[
                        _SectionLabel(label: tr('pinned').toUpperCase()),
                        _buildGrid(pinned, crossAxisCount, isMobile),
                        if (others.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: _SectionLabel(label: tr('others').toUpperCase()),
                          ),
                      ],
                      _buildGrid(others, crossAxisCount, isMobile),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _headerPad),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.38),
                      Colors.black.withValues(alpha: 0.38),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                padding: EdgeInsets.only(top: 20 + safeTop, bottom: 24),
                child: _buildSearchBar(),
              ),
            ),
          ),
                ],
              ),
            ),
          ),
          _buildFab(isMobile, safeBottom),
          _buildBottomNav(width, isMobile, safeBottom),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final sortActive = ref.watch(sortOrderProvider) != SortOrder.defaultValue;
    final focused = _searchFocus.hasFocus;
    return GlassContainer(
      blur: 20,
      borderRadius: 50,
      color: G.bg,
      border: Border.all(
        color: focused ? Colors.white.withValues(alpha: 0.40) : G.border,
      ),
      showInnerEdges: true,
      innerTop: focused ? const Color(0x38FFFFFF) : G.innerTop,
      boxShadow: focused
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ]
          : G.glassShadow(),
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(
                  color: G.textPrimary,
                  fontSize: 15.2,
                  letterSpacing: 0.15,
                ),
                decoration: InputDecoration(
                  hintText: tr('search_hint'),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 15.2),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(LucideIcons.x, size: 16, color: G.textMuted),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ],
            const SizedBox(width: 4),
            _RoundIconButton(
              onTap: () => _showSortSheet(),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      LucideIcons.slidersHorizontal,
                      size: 17,
                      color: sortActive ? const Color(0xE6FFD246) : G.textSecondary,
                    ),
                  ),
                  if (sortActive)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xE6FFC83C),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 6, height: 6),
                      ),
                    ),
                ],
              ),
              highlight: sortActive,
            ),
            const SizedBox(width: 4),
            _RoundIconButton(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: const Icon(LucideIcons.settings, size: 18, color: G.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Note> items, int cols, bool isMobile) {
    if (items.isEmpty) return const SizedBox.shrink();
    final gap = _contentGap;
    final rowCount = (items.length / cols).ceil();
    return Column(
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cols; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(
                    child: row * cols + i < items.length
                        ? NoteCard(note: items[row * cols + i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFab(bool isMobile, double safeBottom) {
    return Positioned(
      bottom: isMobile ? 92 + safeBottom : 32,
      right: isMobile ? 20 : 32,
      child: _FabWithHover(
        size: isMobile ? 52 : 56,
        iconSize: isMobile ? 22 : 24,
        onTap: () => openEditorOverlay(context),
      ),
    );
  }

  Widget _buildBottomNav(double width, bool isMobile, double safeBottom) {
    final currentTab = ref.watch(dashboardTabProvider);
    final navWidth = isMobile
        ? width - 32
        : math.max(260.0, math.min(420.0, width * 0.56));
    final items = <(int, IconData, String)>[
      (0, LucideIcons.fileText, tr('notes')),
      (1, LucideIcons.archive, tr('archive')),
      (2, LucideIcons.trash2, tr('trash')),
    ];
    return Positioned(
      bottom: isMobile ? 12 + safeBottom : 24,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: navWidth,
          child: GlassContainer(
            blur: 28,
            borderRadius: 30,
            showRing: true,
            ringColors: G.ringNav,
            ringStops: G.ringNavStops,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final item in items)
                    _NavItem(
                      icon: item.$2,
                      label: item.$3,
                      active: currentTab == item.$1,
                      onTap: () =>
                          ref.read(dashboardTabProvider.notifier).state = item.$1,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSortSheet() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'sort',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const SortSheetOverlay();
      },
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: G.textMuted,
        ),
      ),
    );
  }
}

class _EmptyTrashButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyTrashButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        blur: 12,
        borderRadius: 11,
        border: Border.all(color: const Color(0x52FF7878)), // rgba(255,120,120,0.32)
        color: const Color(0x2E911423), // rgba(145,20,35,0.18)
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.trash2, size: 13, color: Color(0xF2FFAAAA)),
            const SizedBox(width: 7),
            Text(
              tr('empty_trash_btn'),
              style: const TextStyle(
                fontSize: 12.2,
                fontWeight: FontWeight.w600,
                color: Color(0xF2FFAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tab;
  final bool showingSearch;
  final VoidCallback onCreate;

  const _EmptyState({
    required this.tab,
    required this.showingSearch,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final String msg;
    if (showingSearch) {
      msg = tr('not_found');
    } else if (tab == 1) {
      msg = tr('empty_archive');
    } else if (tab == 2) {
      msg = tr('empty_trash');
    } else {
      msg = tr('no_notes');
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            borderRadius: 14,
            blur: 16,
            child: const SizedBox(
              width: 52,
              height: 52,
              child: Icon(LucideIcons.fileText, size: 22, color: G.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 13.4,
              color: G.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          if (!showingSearch && tab == 0) ...[
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                tr('no_notes_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.2,
                  height: 1.5,
                  color: G.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onCreate,
              child: GlassContainer(
                blur: 14,
                borderRadius: 11,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 14, color: G.textPrimary),
                    const SizedBox(width: 7),
                    Text(
                      tr('create_note'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: G.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool highlight;

  const _RoundIconButton({
    required this.child,
    required this.onTap,
    this.highlight = false,
  });

  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.highlight
                ? const Color(0x1FFFC83C) // rgba(255,200,60,0.12)
                : (_hovered ? Colors.white.withValues(alpha: 0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(50),
            border: widget.highlight
                ? Border.all(color: const Color(0x4DFFC83C))
                : null,
          ),
          child: SizedBox.expand(child: widget.child),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: active ? G.textPrimary : G.textMuted),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.9,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.2,
                    color: active ? G.textPrimary : G.textMuted,
                  ),
                ),
              ],
            ),
            if (active)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FabWithHover extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _FabWithHover({
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

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
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -3.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.04 : 1.0, _isHovered ? 1.04 : 1.0, 1.0),
        child: GlassContainer(
          borderRadius: 18,
          showRing: true,
          showSheen: true,
          ringColors: _isHovered ? G.ringCardHover : G.ringCard,
          ringStops: _isHovered ? G.ringStopsHover : G.ringStops,
          sheenOpacity: _isHovered ? 1.0 : 0.7,
          color: _isHovered ? Colors.white.withValues(alpha: 0.14) : G.bgHov,
          border: Border.all(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.40)
                : G.border,
          ),
          innerTop: _isHovered ? const Color(0x40FFFFFF) : G.innerTop,
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.60),
                    blurRadius: 60,
                    offset: const Offset(0, 22),
                  ),
                  BoxShadow(color: Colors.white.withValues(alpha: 0.10), blurRadius: 24),
                ]
              : G.glassShadow(),
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Icon(
                LucideIcons.plus,
                color: G.textPrimary,
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class SortSheetOverlay extends ConsumerWidget {
  const SortSheetOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortOrderProvider);
    final opts = [
      (SortOrder.defaultValue, tr('sort_default'), tr('sort_default_sub'), LucideIcons.shuffle),
      (SortOrder.created, tr('sort_created'), tr('sort_created_sub'), LucideIcons.calendarDays),
      (SortOrder.updated, tr('sort_updated'), tr('sort_updated_sub'), LucideIcons.refreshCw),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withValues(alpha: 0.52)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return FractionalTranslation(
                translation: Offset(0, 1 - value),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xF5121218),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 60,
                        offset: const Offset(0, -16),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.slidersHorizontal,
                                    size: 16, color: G.textMuted),
                                const SizedBox(width: 10),
                                Text(
                                  tr('sort_title'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.4,
                                    color: G.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                            child: Column(
                              children: [
                                for (final opt in opts)
                                  _SortOption(
                                    title: opt.$2,
                                    subtitle: opt.$3,
                                    icon: opt.$4,
                                    active: current == opt.$1,
                                    onTap: () {
                                      ref.read(sortOrderProvider.notifier).state = opt.$1;
                                      Navigator.pop(context);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: Container(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SortOption extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SortOption> createState() => _SortOptionState();
}

class _SortOptionState extends State<_SortOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: widget.active
                ? Colors.white.withValues(alpha: 0.07)
                : (_hovered ? Colors.white.withValues(alpha: 0.06) : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.active
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.active
                        ? Colors.white.withValues(alpha: 0.20)
                        : G.border,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.active ? G.textPrimary : G.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14.7,
                        color: widget.active ? G.textPrimary : G.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(fontSize: 11.8, color: G.textMuted),
                    ),
                  ],
                ),
              ),
              if (widget.active)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.check, size: 12, color: Color(0xFF111111)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
