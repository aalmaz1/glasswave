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
  
  /// BoxShadow для стеклянных поверхностей
  static List<BoxShadow> get shadows => [
        BoxShadow(
          color: shadow,
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
      ];
  
  /// Gradient border painter
  static CustomPainter gradientBorderPainter({
    List<Color>? colors,
  }) => GradientBorderPainter(colors: colors);
}

/// CustomPainter для градиентной рамки (1px сверху)
class GradientBorderPainter extends CustomPainter {
  final List<Color>? colors;
  
  GradientBorderPainter({this.colors});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(GlassStyle.borderRadius));
    
    // Градиент для рамки: white 35% → white08 40% → white02 100%
    // Только верхняя часть (1px)
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
    
    // Рисуем только верхнюю линию
    final path = Path();
    path.moveTo(0 + GlassStyle.borderRadius, 0);
    path.lineTo(size.width - GlassStyle.borderRadius, 0);
    // Top-right corner
    path.arcToPoint(
      Offset(size.width, 0 + GlassStyle.borderRadius),
      radius: const Radius.circular(GlassStyle.borderRadius),
      clockwise: true,
    );
    // Right side (transparent)
    path.lineTo(size.width, size.height - GlassStyle.borderRadius);
    path.arcToPoint(
      Offset(size.width - GlassStyle.borderRadius, size.height),
      radius: const Radius.circular(GlassStyle.borderRadius),
      clockwise: true,
    );
    // Bottom side (transparent)
    path.lineTo(0 + GlassStyle.borderRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - GlassStyle.borderRadius),
      radius: const Radius.circular(GlassStyle.borderRadius),
      clockwise: true,
    );
    // Left side (transparent)
    path.lineTo(0, 0 + GlassStyle.borderRadius);
    path.arcToPoint(
      Offset(0 + GlassStyle.borderRadius, 0),
      radius: const Radius.circular(GlassStyle.borderRadius),
      clockwise: true,
    );
    path.close();
    
    canvas.drawPath(path, paint);
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
