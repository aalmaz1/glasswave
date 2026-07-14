import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Glassmorphism constants - единая формула для всех поверхностей
class GlassStyle {
  // Background: rgba(255,255,255,0.06)
  static const Color background = Color(0x0FFFFFFF);
  
  // Border: rgba(255,255,255,0.20)
  static const Color border = Color(0x33FFFFFF);
  
  // Border hover: rgba(255,255,255,0.40)
  static const Color borderHover = Color(0x66FFFFFF);
  
  // Shadow: rgba(0,0,0,0.5)
  static const Color shadow = Color(0x80000000);
  
  // Inner glow top: rgba(255,255,255,0.15)
  static const Color innerGlow = Color(0x26FFFFFF);
  
  // Holographic sheen gradient start: rgba(255,255,255,0.06)
  static const Color sheenStart = Color(0x0FFFFFFF);
  
  // Holographic sheen gradient end: rgba(255,255,255,0.03)
  static const Color sheenEnd = Color(0x07FFFFFF);
  
  // Blur sigma
  static const double blurSigma = 24.0;
  
  // Border radius
  static const double borderRadius = 20.0;
  
  // Hover transform
  static const double hoverTranslateY = -6.0;
  static const double hoverScale = 1.02;
  
  /// BoxShadow для стеклянных поверхностей + inner glow сверху
  static List<BoxShadow> get shadows => [
        BoxShadow(
          color: shadow,
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
        // Inner glow сверху
        BoxShadow(
          color: innerGlow,
          blurRadius: 20,
          offset: const Offset(0, -5),
          spreadRadius: -5,
        ),
      ];
  
  /// Gradient border painter - только верхняя 1px рамка с градиентом
  static CustomPainter gradientBorderPainter({
    List<Color>? colors,
  }) => TopGradientBorderPainter(colors: colors);
}

/// CustomPainter для градиентной рамки (только 1px сверху)
/// Градиент: white 35% → white08 40% → white02 100%
class TopGradientBorderPainter extends CustomPainter {
  final List<Color>? colors;
  
  TopGradientBorderPainter({this.colors});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Градиент для верхней рамки: white 35% → white08 40% → white02 100%
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      stops: const [0.35, 0.40, 1.0],
      colors: colors ?? [
        Colors.white,
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.02),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Рисуем ТОЛЬКО верхнюю линию с закруглёнными углами
    final path = Path();
    final radius = GlassStyle.borderRadius;
    
    // Начинаем слева с учётом радиуса
    path.moveTo(radius, 0);
    
    // Верхняя линия до правого угла
    path.lineTo(size.width - radius, 0);
    
    // Правый верхний угол (небольшая дуга для плавности)
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    
    // Не рисуем боковые и нижние грани - только верх!
    // Но для корректного stroke нужно замкнуть путь
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.close();
    
    // Используем clipPath чтобы закрасить только верхнюю часть
    canvas.save();
    // Клип для верхней 1px полосы с закруглёнными углами
    final clipPath = Path();
    clipPath.moveTo(radius, 0);
    clipPath.lineTo(size.width - radius, 0);
    clipPath.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    clipPath.lineTo(size.width, 1);
    clipPath.lineTo(0, 1);
    clipPath.lineTo(0, radius);
    clipPath.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    clipPath.close();
    
    canvas.clipPath(clipPath);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter для полной градиентной рамки (альтернатива)
class GradientBorderPainter extends CustomPainter {
  final List<Color>? colors;
  
  GradientBorderPainter({this.colors});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(GlassStyle.borderRadius));
    
    // Градиент для рамки: white 35% → white08 40% → white02 100%
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.35, 0.40, 1.0],
      colors: colors ?? [
        Colors.white,
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.02),
      ],
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

/// Виджет стеклянной поверхности
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final double? blurSigma;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final bool enableHover;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma,
    this.borderColor,
    this.padding,
    this.decoration,
    this.enableHover = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? GlassStyle.borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma ?? GlassStyle.blurSigma, sigmaY: blurSigma ?? GlassStyle.blurSigma),
        child: Container(
          padding: padding,
          decoration: decoration ??
              BoxDecoration(
                color: GlassStyle.background,
                borderRadius: BorderRadius.circular(borderRadius ?? GlassStyle.borderRadius),
                border: Border.all(
                  color: borderColor ?? GlassStyle.border,
                  width: 1.0,
                ),
                boxShadow: GlassStyle.shadows,
              ),
          child: child,
        ),
      ),
    );
  }
}
