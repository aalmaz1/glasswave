import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Стили стекла (Light/Dark Mode)
enum GlassStyle {
  /// Светлое стекло (Light Mode / Glass)
  /// Фон: rgba(255, 255, 255, 0.06)
  /// Граница: rgba(255, 255, 255, 0.2)
  light,

  /// Тёмное стекло (Dark Mode / Frost)
  /// Фон: rgba(0, 0, 0, 0.4) - среднее между 0.2 и 0.5
  /// Граница: rgba(255, 255, 255, 0.1)
  dark,
}

/// Уровни размытия (Backdrop Blur)
enum GlassBlurLevel {
  /// Мягкое размытие: blur(8-12px) для карточек
  soft,

  /// Стандартное размытие: blur(20px) для основных элементов
  standard,

  /// Сильное размытие: blur(40px) для модальных окон и оверлеев
  strong,
}

/// Универсальный контейнер с эффектом стекла
/// Реализует "бутерброд" из слоёв:
/// 1. Нижний слой: BackdropFilter (размытие)
/// 2. Средний слой: Container с полупрозрачным color
/// 3. Верхний слой: Border (1px) с более высокой непрозрачностью
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassStyle style;
  final GlassBlurLevel blurLevel;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.style = GlassStyle.light,
    this.blurLevel = GlassBlurLevel.standard,
    this.borderRadius = 20.0,
    this.width,
    this.height,
    this.padding,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    final Color borderColor;
    final double sigma;

    // Выбор цветовой схемы
    switch (style) {
      case GlassStyle.light:
        fillColor = const Color.fromRGBO(255, 255, 255, 0.06);
        borderColor = const Color.fromRGBO(255, 255, 255, 0.2);
        break;
      case GlassStyle.dark:
        fillColor = const Color.fromRGBO(0, 0, 0, 0.4);
        borderColor = const Color.fromRGBO(255, 255, 255, 0.1);
        break;
    }

    // Выбор уровня размытия
    switch (blurLevel) {
      case GlassBlurLevel.soft:
        sigma = 10.0; // ~между 8 и 12
        break;
      case GlassBlurLevel.standard:
        sigma = 20.0;
        break;
      case GlassBlurLevel.strong:
        sigma = 40.0;
        break;
    }

    BoxDecoration baseDecoration = BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: borderColor, width: 1.0),
      boxShadow: boxShadow,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: baseDecoration,
          child: child,
        ),
      ),
    );
  }
}

/// Специализированная поисковая строка с многослойными тенями
/// Самый проработанный элемент с комбинацией:
/// - blur(20px)
/// - скругление 50px
/// - многослойные тени (включая внутренние inset shadow для объема)
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

  /// Стиль стекла
  final GlassStyle style;

  const GlassSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSearchPressed,
    this.onSecondaryPressed,
    this.hintText = 'Поиск...',
    this.width,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.06)
        : const Color.fromRGBO(0, 0, 0, 0.4);

    final borderColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.2)
        : const Color.fromRGBO(255, 255, 255, 0.1);

    final textColor = Colors.white;
    final hintColor = style == GlassStyle.light
        ? Colors.white.withOpacity(0.6)
        : Colors.white.withOpacity(0.5);

    final iconColor = Colors.white.withOpacity(0.8);

    return SizedBox(
      width: width ?? 384,
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: borderColor, width: 1),
              ),
              color: fillColor,
              shadows: [
                // Внешняя тень: rgba(0, 0, 0, 0.5) 0px 10px 40px
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  offset: Offset(0, 10),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
                // Внутренний верхний блик: rgba(255, 255, 255, 0.15) 0px 1px 0px inset
                BoxShadow(
                  color: style == GlassStyle.light
                      ? const Color.fromRGBO(255, 255, 255, 0.15)
                      : const Color.fromRGBO(255, 255, 255, 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 0,
                  spreadRadius: -1,
                ),
                // Внутренняя нижняя тень: rgba(0, 0, 0, 0.2) 0px -1px 0px inset
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Поле ввода TextField (без границ)
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.inter(
                        color: hintColor,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                    cursorColor: textColor,
                  ),
                ),
                // Расстояние между элементами (Gap): 4px
                const SizedBox(width: 4),
                // Кнопка поиска
                _GlassIconButton(
                  icon: Icons.search,
                  onPressed: onSearchPressed,
                  iconColor: iconColor,
                ),
                // Расстояние между элементами (Gap): 4px
                const SizedBox(width: 4),
                // Дополнительная кнопка (настройки/фильтры)
                _GlassIconButton(
                  icon: Icons.tune,
                  onPressed: onSecondaryPressed,
                  iconColor: iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Вспомогательная кнопка внутри поисковой строки
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  const _GlassIconButton({
    required this.icon,
    this.onPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Карточка с эффектом Glassmorphism
/// Использует мягкое размытие (soft blur: 8-12px)
/// чтобы контент под ней не слишком отвлекал, но сохранял ощущение глубины
class GlassCard extends StatelessWidget {
  final Widget? child;
  final double width;
  final double height;
  final GlassStyle style;

  const GlassCard({
    super.key,
    this.child,
    this.width = 240,
    this.height = 360,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.25)
        : const Color.fromRGBO(0, 0, 0, 0.2);

    final borderColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.3)
        : const Color.fromRGBO(255, 255, 255, 0.1);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Основной фон с размытием (blur: 15px)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor,
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    // Внешняя тень: 0 8px 32px rgba(0, 0, 0, 0.1)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 8),
                      blurRadius: 32,
                    ),
                    // Внутренний верхний блик: inset 0 1px 0 rgba(255, 255, 255, 0.5)
                    BoxShadow(
                      color: style == GlassStyle.light
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 0,
                      spreadRadius: -1,
                    ),
                    // Внутренний нижний блик: inset 0 -1px 0 rgba(255, 255, 255, 0.1)
                    BoxShadow(
                      color: style == GlassStyle.light
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                      offset: const Offset(0, -1),
                      blurRadius: 0,
                      spreadRadius: -1,
                    ),
                  ],
                ),
              ),
            ),
            // Градиентный блик сверху (::before из CSS)
            // linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      style == GlassStyle.light
                          ? const Color.fromRGBO(255, 255, 255, 0.8)
                          : const Color.fromRGBO(255, 255, 255, 0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Градиентный блик слева (::after из CSS)
            // linear-gradient(180deg, rgba(255, 255, 255, 0.8), transparent, rgba(255, 255, 255, 0.3))
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      style == GlassStyle.light
                          ? const Color.fromRGBO(255, 255, 255, 0.8)
                          : const Color.fromRGBO(255, 255, 255, 0.5),
                      Colors.transparent,
                      style == GlassStyle.light
                          ? const Color.fromRGBO(255, 255, 255, 0.3)
                          : const Color.fromRGBO(255, 255, 255, 0.15),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Контент карточки
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Навигационная панель с эффектом стекла
/// Обычно имеет фиксированное положение и backdrop-filter: blur(20px)
/// чтобы контент страницы красиво размывался при скролле
class GlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;
  final GlassStyle style;

  const GlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.06)
        : const Color.fromRGBO(0, 0, 0, 0.4);

    final borderColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.2)
        : const Color.fromRGBO(255, 255, 255, 0.1);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: destinations,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: style == GlassStyle.light
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}

/// Модальное окно с сильным размытием (blur: 40px)
class GlassModal extends StatelessWidget {
  final Widget child;
  final String title;
  final GlassStyle style;

  const GlassModal({
    super.key,
    required this.child,
    required this.title,
    this.style = GlassStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.06)
        : const Color.fromRGBO(0, 0, 0, 0.5);

    final borderColor = style == GlassStyle.light
        ? const Color.fromRGBO(255, 255, 255, 0.2)
        : const Color.fromRGBO(255, 255, 255, 0.1);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
