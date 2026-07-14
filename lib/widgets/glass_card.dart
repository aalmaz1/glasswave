import 'dart:ui';
import 'package:flutter/material.dart';

/// Виджет карточки с эффектом Glassmorphism
/// Реализует все свойства из CSS спецификации:
/// - Фон: rgba(255, 255, 255, 0.25)
/// - Backdrop blur: 15px
/// - Border radius: 20px
/// - Border: 1px solid rgba(255, 255, 255, 0.3)
/// - Внешняя тень: 0 8px 32px rgba(0, 0, 0, 0.1)
/// - Внутренние блики: inset 0 1px 0 rgba(255, 255, 255, 0.5), inset 0 -1px 0 rgba(255, 255, 255, 0.1)
/// - Градиентные блики сверху и слева (::before и ::after из CSS)
class GlassCard extends StatelessWidget {
  final Widget? child;
  final double width;
  final double height;

  const GlassCard({
    super.key,
    this.child,
    this.width = 240,
    this.height = 360,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Основной фон с размытием
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    // Внешняя тень
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 8),
                      blurRadius: 32,
                    ),
                    // Внутренний верхний блик
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 0,
                      spreadRadius: -1,
                    ),
                    // Внутренний нижний блик
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      offset: const Offset(0, -1),
                      blurRadius: 0,
                      spreadRadius: -1,
                    ),
                  ],
                ),
              ),
            ),
            // Градиентный блик сверху (::before)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color.fromRGBO(255, 255, 255, 0.8),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Градиентный блик слева (::after)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(255, 255, 255, 0.8),
                      Colors.transparent,
                      Color.fromRGBO(255, 255, 255, 0.3),
                    ],
                    stops: [0.0, 0.5, 1.0],
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
