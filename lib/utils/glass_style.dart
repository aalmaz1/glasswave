import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Дизайн-токены (глобальные константы G)
class GlassStyle {
  // Все стеклянные поверхности
  static const Color bg = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color background = bg; // Алиас для совместимости
  static const Color bgHov = Color(0x1AFFFFFF); // 0.10
  static const Color border = Color(0x33FFFFFF); // 0.20
  static const Color borderHover = borderHov; // Алиас для совместимости
  static const Color borderHov = Color(0x66FFFFFF); // 0.40
  
  // Shadow стандартный
  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: Color(0x80000000), // rgba(0,0,0,0.50)
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Color(0x26FFFFFF), // rgba(255,255,255,0.15)
          blurRadius: 20,
          offset: const Offset(0, -5),
          spreadRadius: -10,
        ),
      ];
  static List<BoxShadow> get shadows => shadow; // Алиас для совместимости
  
  // Shadow при наведении
  static List<BoxShadow> get shadowHov => [
        BoxShadow(
          color: Color(0x99000000), // rgba(0,0,0,0.60)
          blurRadius: 60,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: Color(0x40FFFFFF), // rgba(255,255,255,0.25)
          blurRadius: 20,
          offset: const Offset(0, -5),
          spreadRadius: -10,
        ),
      ];
  
  // Border radius
  static const double borderRadius = 20.0;
  
  // Blur значения
  static const double blurStandard = 24.0;
  static const double blurSigma = 24.0; // Алиас для совместимости
  static const double blurNav = 28.0;
  static const double blurEditor = 32.0;
  
  // Текст
  static const Color textPrimary = Color(0xEBFFFFFF); // 0.92
  static const Color textSecondary = Color(0x99FFFFFF); // 0.60
  static const Color textMuted = Color(0x4DFFFFFF); // 0.30
  
  // Overlay
  static const Color overlay = Color(0x80000000); // 0.50
  
  // Hover transform для двухслойной карточки
  static const double hoverTranslateY = -6.0;
  static const double hoverScale = 1.02;
  static const Duration hoverDuration = Duration(milliseconds: 320);
  static const Curve hoverCurve = Curves.elasticOut;
  
  // Градиентная обводка - CustomPainter с точными координатами
  static CustomPainter gradientBorderPainter({bool isHover = false}) =>
      GradientBorderPainter(isHover: isHover);
  
  // Голографический блеск
  static LinearGradient get holographicSheen => const LinearGradient(
        begin: Alignment(-0.71, -0.71),
        end: Alignment(0.71, 0.71),
        colors: [
          Color(0x0FFFFFFF), // 0.06
          Colors.transparent,
          Color(0x08FFFFFF), // 0.03
        ],
        stops: [0.0, 0.5, 1.0],
      );
}

/// CustomPainter для градиентной обводки
class GradientBorderPainter extends CustomPainter {
  final bool isHover;
  
  GradientBorderPainter({this.isHover = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(GlassStyle.borderRadius));
    
    // Градиент от Alignment(-0.64,-0.77) до (0.64,0.77)
    final begin = Alignment(-0.64, -0.77);
    final end = Alignment(0.64, 0.77);
    
    final gradient = LinearGradient(
      begin: begin,
      end: end,
      colors: isHover
          ? [
              const Color(0x99FFFFFF), // 0.60
              const Color(0x24FFFFFF), // 0.14
              const Color(0x05FFFFFF), // 0.02
            ]
          : [
              const Color(0x59FFFFFF), // 0.35
              const Color(0x14FFFFFF), // 0.08
              const Color(0x05FFFFFF), // 0.02
            ],
      stops: const [0.0, 0.40, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(rrect, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Двухслойная карточка с hover эффектом
class DoubleLayerCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minHeight;
  final EdgeInsets padding;
  
  const DoubleLayerCard({
    super.key,
    required this.child,
    this.onTap,
    required this.minHeight,
    required this.padding,
  });
  
  @override
  State<DoubleLayerCard> createState() => _DoubleLayerCardState();
}

/// Стеклянный контейнер (упрощенная версия для статических поверхностей)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = GlassStyle.blurStandard,
    this.borderRadius = GlassStyle.borderRadius,
    this.color = GlassStyle.bg,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius!),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blur!, sigmaY: blur!),
            child: Container(
              padding: padding,
              margin: margin,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius!),
                border: border ?? Border.all(color: GlassStyle.border, width: 1.0),
                boxShadow: boxShadow ?? GlassStyle.shadow,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _DoubleLayerCardState extends State<DoubleLayerCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GlassStyle.hoverDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: GlassStyle.hoverScale).animate(
      CurvedAnimation(parent: _controller, curve: GlassStyle.hoverCurve),
    );
    _translateAnimation = Tween<double>(begin: 0.0, end: GlassStyle.hoverTranslateY).animate(
      CurvedAnimation(parent: _controller, curve: GlassStyle.hoverCurve),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
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
        child: GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GlassStyle.borderRadius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: GlassStyle.blurStandard,
                sigmaY: GlassStyle.blurStandard,
              ),
              child: Container(
                constraints: BoxConstraints(minHeight: widget.minHeight),
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: GlassStyle.bg,
                  borderRadius: BorderRadius.circular(GlassStyle.borderRadius),
                  border: Border.all(
                    color: _isHovered ? GlassStyle.borderHov : GlassStyle.border,
                    width: 1.0,
                  ),
                  boxShadow: _isHovered ? GlassStyle.shadowHov : GlassStyle.shadow,
                ),
                child: Stack(
                  children: [
                    // Акцентный оверлей
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-0.71, -0.71),
                            end: const Alignment(0.71, 0.71),
                            colors: [
                              Colors.amber.withValues(alpha: 0.09),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.70],
                            transform: const GradientRotation(145 * 3.14159 / 180),
                          ),
                        ),
                      ),
                    ),
                    // Голографический блеск
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: GlassStyle.holographicSheen,
                        ),
                      ),
                    ),
                    // Градиентная обводка
                    CustomPaint(
                      painter: GlassStyle.gradientBorderPainter(isHover: _isHovered),
                      size: Size.infinite,
                    ),
                    // Контент
                    widget.child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
