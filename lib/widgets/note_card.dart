import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../themes/app_themes.dart';
import '../utils/glass_style.dart';
import 'gradient_background.dart';

/// Карточка заметки с глассморфизмом и hover-эффектами
class NoteCard extends StatefulWidget {
  final Note note;
  final AppTheme theme;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final VoidCallback? onTrash;
  final VoidCallback? onReminder;
  final bool showActionsAlways;

  const NoteCard({
    super.key,
    required this.note,
    required this.theme,
    this.onTap,
    this.onPin,
    this.onArchive,
    this.onTrash,
    this.onReminder,
    this.showActionsAlways = false,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: GlassStyle.hoverScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _translateAnimation =
        Tween<double>(begin: 0.0, end: GlassStyle.hoverTranslateY).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1280;
    final showActions = widget.showActionsAlways || _isHovered;

    final accentColor = widget.theme
        .accentColors[widget.note.accentIdx % widget.theme.accentColors.length];

    // OUTER layer: GestureDetector + Transform (NO overflow:hidden - shadow must not be clipped)
    Widget card = MouseRegion(
      onEnter: (_) => isDesktop ? _onHoverEnter() : null,
      onExit: (_) => isDesktop ? _onHoverExit() : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          // INNER layer: Container with glassmorphism + overflow:hidden for content
          child: _buildCardInner(accentColor, showActions),
        ),
      ),
    );

    return card;
  }

  Widget _buildCardInner(Color accentColor, bool showActions) {
    return Container(
      // Outer container handles border and shadow (no clip)
      decoration: BoxDecoration(
        color: GlassStyle.background,
        borderRadius: BorderRadius.circular(GlassStyle.borderRadius),
        border: Border.all(
          color: _isHovered ? GlassStyle.borderHover : GlassStyle.border,
          width: 1.0,
        ),
        boxShadow: GlassStyle.shadows,
      ),
      child: ClipRRect(
        // Inner clip for content overflow only
        borderRadius: BorderRadius.circular(GlassStyle.borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: _isHovered ? 28 : GlassStyle.blurSigma,
            sigmaY: _isHovered ? 28 : GlassStyle.blurSigma,
          ),
          child: Stack(
            children: [
              // Accent gradient (very weak, max opacity 0.08)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor, Colors.transparent],
                  ),
                ),
              ),

              // Holographic sheen overlay
              const HolographicSheen(),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: title + pin button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Pin button (shown on hover)
                        AnimatedOpacity(
                          opacity: showActions ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            icon: Icon(
                              widget.note.pinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: widget.note.pinned
                                  ? Colors.amber
                                  : Colors.white70,
                              size: 18,
                            ),
                            onPressed: widget.onPin,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Body text (3 lines max in grid mode)
                    Expanded(
                      child: Text(
                        widget.note.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Reminder badge
                    if (widget.note.reminder != null) ...[
                      _buildReminderBadge(),
                      const SizedBox(height: 8),
                    ],

                    // Footer: date + actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date
                        Text(
                          _formatDate(widget.note.updatedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),

                        // Action buttons
                        AnimatedOpacity(
                          opacity: showActions ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!widget.note.trashed) ...[
                                _ActionButton(
                                  icon: Icons.notifications_outlined,
                                  onTap: widget.onReminder,
                                  isActive: widget.note.reminder != null,
                                ),
                                const SizedBox(width: 8),
                                _ActionButton(
                                  icon: widget.note.archived
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined,
                                  onTap: widget.onArchive,
                                ),
                                const SizedBox(width: 8),
                              ],
                              _ActionButton(
                                icon: widget.note.trashed
                                    ? Icons.delete_forever
                                    : Icons.delete_outline,
                                onTap: widget.onTrash,
                                isDestructive: widget.note.trashed,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Gradient border overlay (z-index top)
              CustomPaint(
                painter: GradientBorderPainter(),
                size: Size.infinite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            _formatReminderDate(widget.note.reminder!),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Сегодня';
    } else if (diff.inDays == 1) {
      return 'Вчера';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн. назад';
    }

    return DateFormat('d MMM', 'ru').format(date);
  }

  String _formatReminderDate(DateTime date) {
    return DateFormat('d MMM, HH:mm', 'ru').format(date);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber.withValues(alpha: 0.2)
              : isDestructive
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive
              ? Colors.amber
              : isDestructive
                  ? Colors.red
                  : Colors.white70,
        ),
      ),
    );
  }
}
