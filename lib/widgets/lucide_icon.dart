import 'package:flutter/material.dart';

/// Виджет для отображения иконок Lucide через SVG
/// Используется для соответствия оригинальному дизайну Figma
class LucideIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const LucideIcon({
    super.key,
    required this.name,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Заглушка для будущих иконок Lucide
    // Для использования добавьте пакет lucide_icons в pubspec.yaml
    // и импортируйте: import 'package:lucide_icons/lucide_icons.dart';
    return Icon(
      _getIconData(name),
      size: size,
      color: color ?? Colors.white,
    );
  }

  IconData _getIconData(String name) {
    // Временная маппинг-функция до установки lucide_icons
    switch (name) {
      case 'star':
        return Icons.star_outline;
      case 'search':
        return Icons.search;
      case 'settings':
        return Icons.settings;
      case 'sort':
        return Icons.sort;
      case 'plus':
        return Icons.add;
      case 'trash':
        return Icons.delete_outline;
      case 'archive':
        return Icons.archive;
      case 'pin':
        return Icons.push_pin;
      case 'bell':
        return Icons.notifications_none;
      default:
        return Icons.circle_outlined;
    }
  }
}
