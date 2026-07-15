import 'package:flutter/material.dart';
import 'dart:ui';

/// Дизайн-токены для стеклянных элементов (согласно Figma)
class G {
  static const bg = Color.fromRGBO(255, 255, 255, 0.06);
  static const bgHov = Color.fromRGBO(255, 255, 255, 0.10);
  static const border = Color.fromRGBO(255, 255, 255, 0.20);
  static const borderHov = Color.fromRGBO(255, 255, 255, 0.40);
  static const shadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.50),
    blurRadius: 40,
    offset: Offset(0, 10),
  );
  static const shadowHov = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.60),
    blurRadius: 60,
    offset: Offset(0, 20),
  );
  static const radius = 20.0;
  static const textPrimary = Color.fromRGBO(255, 255, 255, 0.92);
  static const textSecondary = Color.fromRGBO(255, 255, 255, 0.60);
  static const textMuted = Color.fromRGBO(255, 255, 255, 0.30);
  static const overlay = Color.fromRGBO(0, 0, 0, 0.50);
}

/// Стеклянная карточка с эффектом при наведении
/// Точное соответствие Figma:
/// - BackdropFilter blur(24px)
/// - Фон rgba(255, 255, 255, 0.06)
/// - Рамка 0.9px solid rgba(255, 255, 255, 0.2)
/// - Анимация: translateY(-6px) scale(1.02) с cubic-bezier(0.34, 1.56, 0.64, 1)
/// - Шрифт Roboto
class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool enableHover;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.accentColor,
    this.enableHover = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.enableHover ? setState(() => _isHovered = true) : null,
      onExit: (_) => widget.enableHover ? setState(() => _isHovered = false) : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Cubic(0.34, 1.56, 0.64, 1), // cubic-bezier из CSS
          margin: widget.margin,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0, -6)..scale(1.02))
              : Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(G.radius),
            child: Stack(
              children: [
                // Размытие фона (sigma 24px как в Figma)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(),
                ),
                // Фоновый цвет: rgba(255, 255, 255, 0.06)
                Container(
                  decoration: BoxDecoration(
                    color: _isHovered ? G.bgHov : G.bg,
                    borderRadius: BorderRadius.circular(G.radius),
                  ),
                ),
                // Акцентный слой (опционально)
                if (widget.accentColor != null)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor!.withOpacity(0.15),
                          widget.accentColor!.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(G.radius),
                    ),
                  ),
                // Слой "стеклянного кольца" - градиент от верхнего левого к нижнему правому
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(G.radius),
                  ),
                ),
                // Слой общего отблеска
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.06),
                        Colors.transparent,
                        Colors.white.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(G.radius),
                  ),
                ),
                // Рамка: 0.9px solid rgba(255, 255, 255, 0.2)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isHovered ? G.borderHov : G.border,
                      width: 0.9,
                    ),
                    borderRadius: BorderRadius.circular(G.radius),
                  ),
                ),
                // Тень
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [_isHovered ? G.shadowHov : G.shadow],
                    borderRadius: BorderRadius.circular(G.radius),
                  ),
                ),
                // Контент с шрифтом Roboto (fallback)
                Padding(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'Roboto', // Fallback to default font
                      color: G.textPrimary,
                    ),
                    child: widget.child,
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
