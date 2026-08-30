import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? accentGradient;
  final EdgeInsetsGeometry? padding;

  final bool showRing;
  final List<Color> ringColors;
  final List<double> ringStops;

  final bool showSheen;
  final double sheenOpacity;

  final bool showInnerEdges;
  final Color innerTop;
  final Color innerBottom;

  final StackFit fit;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.borderRadius = 20.0,
    this.color,
    this.border,
    this.boxShadow,
    this.accentGradient,
    this.padding,
    this.showRing = false,
    this.ringColors = G.ringCard,
    this.ringStops = G.ringStops,
    this.showSheen = false,
    this.sheenOpacity = G.sheenOpacity,
    this.showInnerEdges = true,
    this.innerTop = G.innerTop,
    this.innerBottom = G.innerBottom,
    this.fit = StackFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(borderRadius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? G.glassShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: fit,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: color ?? G.bg,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: border ?? Border.all(color: G.border, width: 1.0),
                  ),
                ),
              ),
            ),
            if (accentGradient != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            if (showSheen)
              Positioned.fill(
                child: Opacity(
                  opacity: sheenOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.03),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            if (showInnerEdges) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(color: innerTop),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(color: innerBottom),
              ),
            ],
            if (showRing)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _RingPainter(
                      radius: radius,
                      colors: ringColors,
                      stops: ringStops,
                    ),
                  ),
                ),
              ),
            if (padding != null)
              Padding(padding: padding!, child: child)
            else
              child,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Radius radius;
  final List<Color> colors;
  final List<double> stops;

  _RingPainter({required this.radius, required this.colors, required this.stops});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: const Alignment(-0.34, -0.94),
        end: const Alignment(0.34, 0.94),
        colors: colors,
        stops: stops,
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        !listEquals(oldDelegate.colors, colors) ||
        !listEquals(oldDelegate.stops, stops);
  }
}

class GlassChip extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool highlight;

  const GlassChip({
    super.key,
    required this.child,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          blur: 16,
          borderRadius: 12,
          color: highlight ? G.bgHov : G.bg,
          border: Border.all(
            color: highlight
                ? Colors.white.withValues(alpha: 0.35)
                : G.border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: child,
        ),
      ),
    );
  }
}
