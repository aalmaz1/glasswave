import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? accentGradient;
  final EdgeInsetsGeometry? padding;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(
                  color: color ?? Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: border ?? Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            // Accent gradient (if any)
            if (accentGradient != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            // Ring / Shine (simplified)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            if (padding != null)
              Padding(
                padding: padding!,
                child: child,
              )
            else
              child,
          ],
        ),
      ),
    );
  }
}
