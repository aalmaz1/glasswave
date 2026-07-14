import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Виджет поисковой строки с эффектом Glassmorphism
/// 
/// Спецификации дизайна:
/// - Высота: 52px, ширина: 384px (или адаптивная)
/// - BackdropFilter blur(20px)
/// - Фон: rgba(255, 255, 255, 0.06)
/// - Border radius: 50
/// - Обводка: 1px, rgba(255, 255, 255, 0.2)
/// - Тень: rgba(0, 0, 0, 0.5), offset (0, 10), blurRadius 40
/// - Внутренние блики: верхний rgba(255, 255, 255, 0.15) и нижний rgba(0, 0, 0, 0.2)
class GlassSearchBar extends StatelessWidget {
  /// Контроллер для поля ввода
  final TextEditingController? controller;

  /// Callback при изменении текста
  final ValueChanged<String>? onChanged;

  /// Callback при нажатии на кнопку поиска
  final VoidCallback? onSearchPressed;

  /// Callback при нажатии на дополнительную кнопку
  final VoidCallback? onSecondaryPressed;

  /// Текст подсказки
  final String hintText;

  /// Ширина виджета (по умолчанию 384px)
  final double? width;

  const GlassSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSearchPressed,
    this.onSecondaryPressed,
    this.hintText = 'Поиск...',
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 384,
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.06),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                width: 1,
              ),
              boxShadow: [
                // Внешняя тень
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  offset: Offset(0, 10),
                  blurRadius: 40,
                ),
                // Верхний внутренний блик
                BoxShadow(
                  color: const Color.fromRGBO(255, 255, 255, 0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 0,
                  spreadRadius: -1,
                ),
                // Нижний внутренний блик (тень)
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.2),
                  offset: const Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: -1,
                ),
              ],
            ),
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Поле ввода
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                  ),
                ),
                // Разделитель
                const SizedBox(width: 4),
                // Кнопка поиска
                IconButton(
                  onPressed: onSearchPressed,
                  icon: const Icon(
                    Icons.search,
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                // Разделитель
                const SizedBox(width: 4),
                // Дополнительная кнопка
                IconButton(
                  onPressed: onSecondaryPressed,
                  icon: const Icon(
                    Icons.tune,
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
