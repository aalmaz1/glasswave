import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/note.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme_data.dart';
import 'glass_container.dart';
import 'reminder_modal.dart';
import '../screens/editor_screen.dart';

class NoteCard extends ConsumerStatefulWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _isHovered = false;

  String _fmtDate(DateTime d, String locale) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return tr('note_just_now');
    if (diff.inHours < 24) return "${diff.inHours}${tr('note_hours_ago')}";
    if (diff.inDays < 7) return "${diff.inDays}${tr('note_days_ago')}";
    return DateFormat("d MMM", locale == 'ru' ? 'ru_RU' : 'en_US').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final accent = theme.accents[widget.note.accentIdx % theme.accents.length];
    final locale = context.locale.languageCode;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _isHovered && !isMobile ? -6.0 : 0.0, 0.0, 0.0)
          ..scaleByDouble(isMobile ? 1.0 : (_isHovered ? 1.02 : 1.0), isMobile ? 1.0 : (_isHovered ? 1.02 : 1.0), isMobile ? 1.0 : (_isHovered ? 1.02 : 1.0), 1.0),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(note: widget.note))),
          child: GlassContainer(
            borderRadius: 20,
            blur: _isHovered && !isMobile ? 32 : 24,
            color: _isHovered && !isMobile
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.06),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered && !isMobile ? 0.6 : 0.5),
                blurRadius: _isHovered && !isMobile ? 60 : 40,
                offset: Offset(0, _isHovered && !isMobile ? 20 : 10),
              ),
            ],
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: _isHovered && !isMobile ? 1.0 : 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.note.title,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Opacity(
                            opacity: (widget.note.pinned || _isHovered || isMobile) ? 1.0 : 0.0,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                widget.note.pinned ? LucideIcons.pinOff : LucideIcons.pin,
                                size: 16,
                                color: widget.note.pinned ? Colors.white : Colors.white30,
                              ),
                              onPressed: () => ref.read(notesProvider.notifier).togglePin(widget.note.id),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MarkdownBody(
                        data: widget.note.body.isEmpty ? " " : widget.note.body,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            height: 1.6,
                          ),
                          strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                          listBullet: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.note.reminder != null)
                        _buildReminderBadge(widget.note.reminder!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.clock, size: 10, color: Colors.white30),
                              const SizedBox(width: 4),
                              Text(
                                _fmtDate(widget.note.updatedAt, locale),
                                style: const TextStyle(color: Colors.white30, fontSize: 10),
                              ),
                            ],
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: (isMobile || _isHovered) ? 1.0 : 0.0,
                            child: Row(
                              children: [
                                _miniAction(
                                  icon: LucideIcons.bell,
                                  color: widget.note.reminder != null ? Colors.amber : Colors.white30,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ReminderModal(
                                        initialDate: widget.note.reminder,
                                        onSave: (d) => ref.read(notesProvider.notifier).setReminder(widget.note.id, d),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                if (!widget.note.archived)
                                  _miniAction(
                                    icon: LucideIcons.archive,
                                    color: Colors.white30,
                                    onTap: () => ref.read(notesProvider.notifier).toggleArchive(widget.note.id),
                                  ),
                                const SizedBox(width: 4),
                                _miniAction(
                                  icon: LucideIcons.trash2,
                                  color: Colors.white30,
                                  onTap: () => ref.read(notesProvider.notifier).toggleTrash(widget.note.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderBadge(DateTime d) {
    final locale = context.locale.languageCode;
    final dateLocale = locale == 'ru' ? 'ru_RU' : 'en_US';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ReminderModal(
            initialDate: widget.note.reminder,
            onSave: (date) => ref.read(notesProvider.notifier).setReminder(widget.note.id, date),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.bellRing, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              DateFormat("d MMM, HH:mm", dateLocale).format(d),
              style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
