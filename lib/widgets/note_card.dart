import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/theme_data.dart';
import '../providers/app_provider.dart';
import '../utils/date_formatter.dart';
import 'glass_card.dart';

/// Карточка заметки со всеми действиями
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onTrash;
  final VoidCallback onReminder;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onArchive,
    required this.onTrash,
    required this.onReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appState, _) {
        final theme = appState.currentTheme;
        final accentColor = theme.accentColors.isNotEmpty
            ? theme.accentColors[note.accentIdx % theme.accentColors.length]
            : null;

        return GlassCard(
          accentColor: accentColor,
          onTap: onTap,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Без названия' : note.title,
                      style: const TextStyle(
                        color: G.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Закрепить
                  IconButton(
                    icon: Icon(
                      note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: note.pinned ? accentColor : G.textSecondary,
                      size: 18,
                    ),
                    onPressed: onPin,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Напоминание
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          note.reminder != null
                              ? Icons.notifications
                              : Icons.notifications_none,
                          color: note.reminder != null
                              ? accentColor
                              : G.textSecondary,
                          size: 18,
                        ),
                        if (note.reminder != null)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accentColor ?? Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: onReminder,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Архив/Корзина
                  IconButton(
                    icon: Icon(
                      note.archived ? Icons.unarchive : Icons.archive,
                      color: G.textSecondary,
                      size: 18,
                    ),
                    onPressed: onArchive,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Удалить
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: G.textSecondary,
                      size: 18,
                    ),
                    onPressed: onTrash,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Текст заметки
          Expanded(
            child: Text(
              note.body.isEmpty ? 'Пустая заметка' : note.body,
              style: const TextStyle(
                color: G.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: note.title.isEmpty ? 5 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // Дата и бейдж напоминания
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatRelative(note.updatedAt),
                style: const TextStyle(
                  color: G.textMuted,
                  fontSize: 12,
                ),
              ),
              if (note.reminder != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor?.withOpacity(0.4) ?? Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    DateFormatter.formatReminder(note.reminder!),
                    style: TextStyle(
                      color: accentColor ?? Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
