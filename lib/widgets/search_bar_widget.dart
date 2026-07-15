import 'package:flutter/material.dart';
import 'dart:ui';

/// Стеклянная поисковая строка
class GlassSearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSort;
  final VoidCallback? onSettings;

  const GlassSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSort,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Поиск
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: TextEditingController(text: value),
                    onChanged: onChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск заметок...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              // Кнопка сортировки
              if (onSort != null)
                IconButton(
                  icon: Icon(Icons.tune, color: Colors.white.withOpacity(0.7)),
                  onPressed: onSort,
                  tooltip: 'Сортировка',
                ),
              // Кнопка настроек
              if (onSettings != null)
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white.withOpacity(0.7)),
                  onPressed: onSettings,
                  tooltip: 'Настройки',
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
