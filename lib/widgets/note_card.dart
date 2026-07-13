import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../themes/app_theme.dart';

/// Карточка заметки с полным глассморфизмом
class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final VoidCallback? onTrash;
  final VoidCallback? onReminder;
  final AppTheme theme;
  final bool isMobile;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onPin,
    this.onArchive,
    this.onTrash,
    this.onReminder,
    required this.theme,
    this.isMobile = true,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isHovered = false;

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, HH:mm', 'ru').format(date);
  }

  String _formatReminder(DateTime reminder) {
    return DateFormat('d MMM, HH:mm', 'ru').format(reminder);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.theme.getAccentColor(widget.note.accentIdx);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0, _isHovered ? -6 : 0)
          ..scale(_isHovered ? 1.02 : 1.0),
        child: Stack(
          children: [
            // Основной контейнер с глассморфизмом
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0x0FFFFFFF),
                border: Border.all(
                  color: _isHovered 
                      ? const Color(0x66FFFFFF)
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x80000000),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0x26FFFFFF),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Stack(
                      children: [
                        // Акцентный градиент
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              rotation: 145 * 3.14159 / 180,
                              colors: [accentColor, Colors.transparent],
                            ),
                          ),
                        ),
                        // Контент
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок + кнопка Pin
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.note.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Кнопка Pin (скрыта, показывается при hover или на мобиле)
                                  if (_isHovered || widget.isMobile || widget.note.pinned)
                                    AnimatedScale(
                                      scale: widget.note.pinned ? 1.0 : (_isHovered ? 1.0 : 0.75),
                                      duration: const Duration(milliseconds: 200),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.push_pin_rounded,
                                          color: widget.note.pinned 
                                              ? const Color(0xFFFFB74D)
                                              : Colors.white.withOpacity(0.5),
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: widget.onPin,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Тело заметки
                              Text(
                                widget.note.body,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                maxLines: widget.isMobile ? 3 : 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              // Reminder badge
                              if (widget.note.reminder != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBC04).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.notifications_active_rounded,
                                        color: Color(0xFFFBBC04),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatReminder(widget.note.reminder!),
                                        style: const TextStyle(
                                          color: Color(0xFFFBBC04),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Footer: дата + action кнопки
                              Row(
                                children: [
                                  // Дата
                                  Text(
                                    _formatDate(widget.note.updatedAt),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Action кнопки (скрыты, появляются при hover)
                                  if (_isHovered || widget.isMobile)
                                    FadeInActionButtons(
                                      isVisible: _isHovered || widget.isMobile,
                                      onArchive: widget.onArchive,
                                      onTrash: widget.onTrash,
                                      onReminder: widget.onReminder,
                                      hasReminder: widget.note.reminder != null,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Голографический блеск
                        CustomPaint(
                          painter: _HolographicSheenPainter(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Градиентная рамка
            Positioned.fill(
              child: CustomPaint(
                painter: _GradientBorderPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Анимированные action-кнопки
class FadeInActionButtons extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onArchive;
  final VoidCallback? onTrash;
  final VoidCallback? onReminder;
  final bool hasReminder;

  const FadeInActionButtons({
    super.key,
    required this.isVisible,
    this.onArchive,
    this.onTrash,
    this.onReminder,
    this.hasReminder = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reminder button
          IconButton(
            icon: Icon(
              hasReminder ? Icons.notifications_active_rounded : Icons.add_alarm_rounded,
              color: hasReminder ? const Color(0xFFFBBC04) : Colors.white.withOpacity(0.5),
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onReminder,
          ),
          // Archive button
          IconButton(
            icon: Icon(
              Icons.archive_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onArchive,
          ),
          // Trash button
          IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onTrash,
          ),
        ],
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      rotation: 160 * 3.14159 / 180,
      colors: [
        const Color(0xFFFFFFFF),
        const Color(0xFFFFFFFF).withOpacity(0.35),
        const Color(0x1AFFFFFF),
        const Color(0x05FFFFFF),
      ],
      stops: const [0.0, 0.35, 0.40, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HolographicSheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      rotation: 45 * 3.14159 / 180,
      colors: [
        const Color(0x0AFFFFFF),
        Colors.transparent,
        const Color(0x08FFFFFF),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.overlay;
    
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
