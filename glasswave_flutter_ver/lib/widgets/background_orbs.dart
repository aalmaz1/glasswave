import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_data.dart';

/// Background orbs matching the React reference implementation:
/// `radial-gradient(circle, color 0%, transparent 68%)` + `blur(2px)`, with a
/// per-orb parallax of `translateY(scrollTop * (0.07 + i * 0.05))`.
///
/// The parallax listens to [scrollY] through a [ValueListenable] so scrolling
/// repaints only this layer — React mutates the orb transforms directly for
/// exactly the same reason (a state update per frame re-rendered the grid).
class BackgroundOrbs extends StatelessWidget {
  final AppThemeData theme;
  final ValueListenable<double>? scrollY;

  const BackgroundOrbs({super.key, required this.theme, this.scrollY});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: theme.bgGradient(size)),
          ),
        ),
        ...theme.orbs.asMap().entries.map((entry) {
          final i = entry.key;
          final orb = entry.value;
          // React: `translateY(scrollTop * (0.07 + i * 0.05))`
          final parallax = 0.07 + i * 0.05;
          final orbWidget = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: orb.size,
              height: orb.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [orb.color, orb.color.withValues(alpha: 0)],
                  stops: const [0.0, 0.68],
                ),
              ),
            ),
          );
          return Positioned(
            top: size.height * orb.top,
            left: size.width * orb.left,
            child: scrollY == null
                ? orbWidget
                : ValueListenableBuilder<double>(
                    valueListenable: scrollY!,
                    child: orbWidget,
                    builder: (context, offset, child) => Transform.translate(
                      offset: Offset(0, offset * parallax),
                      child: child,
                    ),
                  ),
          );
        }),
      ],
    );
  }
}
