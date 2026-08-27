import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/note.dart';
import '../providers/app_providers.dart';
import '../services/welcome_notes.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';
import 'glass_container.dart';
import 'reminder_modal.dart';
import 'confirm_dialog.dart';
import '../screens/editor_screen.dart';

/// Note card matching the React Native `NoteCard` 1:1:
/// min-height 130/140/160, padding 14x16 / 18x20, title 700, body clamped to
/// 3 lines, amber reminder badge, clock + date footer and three mini actions.
class NoteCard extends ConsumerStatefulWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _isHovered = false;

  String _dateLocale(String langCode) {
    switch (langCode) {
      case 'ru':
        return 'ru_RU';
      case 'ko':
        return 'ko_KR';
      default:
        return 'en_US';
    }
  }

  /// React `fmtDate()` (src/app/utils.ts): just now → minutes → hours →
  /// yesterday → days → "27 August".
  String _fmtDate(DateTime d, String locale) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return tr('note_just_now');
    if (diff.inMinutes < 60) {
      return tr('note_min_ago', namedArgs: {'n': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return tr('note_hours_ago', namedArgs: {'n': '${diff.inHours}'});
    }
    if (diff.inDays == 1) return tr('note_yesterday');
    if (diff.inDays < 7) {
      return tr('note_days_ago', namedArgs: {'n': '${diff.inDays}'});
    }
    return DateFormat('d MMMM', _dateLocale(locale)).format(d);
  }

  void _openReminder() {
    showReminderModal(
      context,
      initialDate: widget.note.reminder,
      onSave: (d) => ref.read(notesProvider.notifier).setReminder(widget.note.id, d),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final accent = theme.accents[widget.note.accentIdx % theme.accents.length];
    final locale = context.locale.languageCode;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1280;
    final tabIndex = ref.watch(dashboardTabProvider);
    final hoverActive = !isMobile && _isHovered;
    // Welcome/demo cards are read-only samples: tap to open, but no pin or
    // archive actions — they aren't real notes yet (React `isDemo`).
    final isDemo = isWelcomeNoteId(widget.note.id);

    final minH = isMobile ? 130.0 : (isTablet ? 140.0 : 160.0);
    final pad = isMobile
        ? const EdgeInsets.fromLTRB(16, 14, 16, 12)
        : const EdgeInsets.fromLTRB(20, 18, 20, 14);
    final titleFont = isMobile ? 14.4 : (isTablet ? 15.4 : 17.0);
    final bodyFont = isMobile ? 12.2 : (isTablet ? 12.8 : 13.4);
    final hasReminder = widget.note.reminder != null;

    void openEditor() {
      // Editing a demo card behaves like creating a note (React `persistNote`).
      openEditorOverlay(context, note: widget.note, asNewNote: isDemo);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
        transform: Matrix4.identity()
          ..translate(0.0, hoverActive ? -6.0 : 0.0, 0.0)
          ..scale(hoverActive ? 1.02 : 1.0, hoverActive ? 1.02 : 1.0, 1.0),
        child: GestureDetector(
          onTap: openEditor,
          child: GlassContainer(
            borderRadius: 20,
            blur: 24,
            hover: hoverActive,
            color: hoverActive ? G.bgHov : G.bg,
            border: Border.all(color: hoverActive ? G.borderHov : G.border),
            boxShadow: G.glassShadow(hover: hoverActive),
            accentGradient: LinearGradient(
              // React: `linear-gradient(145deg, accent 0%, rgba(255,255,255,0.01) 70%)`
              // and `filter: brightness(1.6)` while hovered.
              // 145° on a landscape card (~300x160) resolves to these ends.
              begin: const Alignment(-0.58, -1.55),
              end: const Alignment(0.58, 1.55),
              colors: [
                hoverActive ? _brightness(accent, 1.6) : accent,
                Colors.white.withValues(alpha: 0.01),
              ],
              stops: const [0.0, 0.7],
            ),
            fit: StackFit.expand,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minH),
              child: Padding(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.note.title.isEmpty ? tr('editor_no_title') : widget.note.title,
                            style: TextStyle(
                              color: G.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: titleFont,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isDemo)
                          _PinButton(
                            pinned: widget.note.pinned,
                            onTap: () =>
                                ref.read(notesProvider.notifier).togglePin(widget.note.id),
                          )
                        // Demo cards render a static pin glyph (no button).
                        else if (widget.note.pinned)
                          const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              LucideIcons.pin,
                              size: 14,
                              color: Color(0xB3FFFFFF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _plainPreview(widget.note.body),
                        style: TextStyle(
                          color: G.textSecondary,
                          fontSize: bodyFont,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasReminder && widget.note.reminder != null) ...[
                      _ReminderBadge(
                        date: widget.note.reminder!,
                        locale: locale,
                        dateLocale: _dateLocale(locale),
                        onTap: _openReminder,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.clock, size: 9, color: G.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              _fmtDate(widget.note.updatedAt, locale),
                              style: const TextStyle(
                                fontSize: 10.9,
                                color: G.textMuted,
                              ),
                            ),
                          ],
                        ),
                        if (!isDemo)
                          AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: (isMobile || _isHovered) ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !isMobile && !_isHovered,
                            child: Row(
                              children: tabIndex == 2
                                  ? [
                                      _MiniAction(
                                        icon: LucideIcons.rotateCcw,
                                        color: G.textSecondary,
                                        onTap: () => ref
                                            .read(notesProvider.notifier)
                                            .toggleTrash(widget.note.id),
                                      ),
                                      const SizedBox(width: 4),
                                      _MiniAction(
                                        icon: LucideIcons.trash2,
                                        color: const Color(0xE6FF8C8C),
                                        onTap: () async {
                                          final result = await showGlassConfirm(
                                            context,
                                            title: tr('confirm_delete_title'),
                                            body: tr('confirm_delete_body'),
                                            confirmLabel: tr('delete_forever'),
                                            cancelLabel: tr('cancel'),
                                          );
                                          if (result == GlassConfirmChoice.confirm &&
                                              mounted) {
                                            ref
                                                .read(notesProvider.notifier)
                                                .deleteNote(widget.note.id);
                                          }
                                        },
                                      ),
                                    ]
                                  : [
                                      _MiniAction(
                                        icon: LucideIcons.bell,
                                        color: hasReminder
                                            ? const Color(0xCCFFC83C)
                                            : G.textSecondary,
                                        onTap: _openReminder,
                                      ),
                                      const SizedBox(width: 4),
                                      _MiniAction(
                                        icon: LucideIcons.archive,
                                        color: G.textSecondary,
                                        onTap: () => ref
                                            .read(notesProvider.notifier)
                                            .toggleArchive(widget.note.id),
                                      ),
                                      const SizedBox(width: 4),
                                      _MiniAction(
                                        icon: LucideIcons.trash2,
                                        color: G.textSecondary,
                                        onTap: () => ref
                                            .read(notesProvider.notifier)
                                            .toggleTrash(widget.note.id),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The React card preview renders `stripHtml(note.body)` — plain text without
/// any formatting marks. The Flutter editor stores Markdown, so drop the
/// syntax characters to get the same look.
String _plainPreview(String body) {
  var out = body;
  out = out.replaceAll(RegExp(r'^[ \t]{0,3}#{1,6}[ \t]+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^[ \t]{0,3}>[ \t]?', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^[ \t]{0,3}[-*+][ \t]+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^[ \t]{0,3}\d+\.[ \t]+', multiLine: true), '');
  out = out.replaceAll(
      RegExp(r'^[ \t]{0,3}(-{3,}|\*{3,}|_{3,})[ \t]*$', multiLine: true), '');
  out = out.replaceAll(RegExp(r'`{1,3}'), '');
  out = out.replaceAll(RegExp(r'(\*\*|__|~~)'), '');
  out = out.replaceAll(RegExp(r'\n{2,}'), '\n');
  return out.trim();
}

/// CSS `filter: brightness(f)` — scales the colour channels, keeps the alpha.
Color _brightness(Color c, double f) => Color.from(
      alpha: c.a,
      red: (c.r * f).clamp(0.0, 1.0),
      green: (c.g * f).clamp(0.0, 1.0),
      blue: (c.b * f).clamp(0.0, 1.0),
    );

class _PinButton extends StatelessWidget {
  final bool pinned;
  final VoidCallback onTap;

  const _PinButton({required this.pinned, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          pinned ? LucideIcons.pinOff : LucideIcons.pin,
          size: 14,
          color: pinned
              ? Colors.white.withValues(alpha: 0.70)
              : G.textSecondary,
        ),
      ),
    );
  }
}

class _ReminderBadge extends StatelessWidget {
  final DateTime date;
  final String locale;
  final String dateLocale;
  final VoidCallback onTap;

  const _ReminderBadge({
    required this.date,
    required this.locale,
    required this.dateLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, HH:mm', dateLocale);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
        decoration: BoxDecoration(
          color: const Color(0x1FFFC83C), // rgba(255,200,60,0.12)
          border: Border.all(color: const Color(0x47FFC83C)), // 0.28
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.bellRing, size: 10, color: Color(0xE6FFD250)),
            const SizedBox(width: 5),
            Text(
              fmt.format(date),
              style: const TextStyle(
                fontSize: 10.9,
                fontWeight: FontWeight.w600,
                color: Color(0xE6FFD250),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: G.bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Icon(icon, size: 11, color: color)),
      ),
    );
  }
}
