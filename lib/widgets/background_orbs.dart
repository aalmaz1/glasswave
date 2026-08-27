import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_data.dart';

/// Background orbs matching the React Native implementation:
/// radial-gradient to 68% + `blur(2px)`, parallax `0.07 + i * 0.05` on scroll.
class BackgroundOrbs extends StatelessWidget {
  final AppThemeData theme;
  final double scrollY;

  const BackgroundOrbs({super.key, required this.theme, this.scrollY = 0});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: theme.bg)),
        ...theme.orbs.asMap().entries.map((entry) {
          final i = entry.key;
          final orb = entry.value;
          // React: `translateY(scrollTop * (0.07 + i * 0.05))`
          final parallax = 0.07 + i * 0.05;
          return Positioned(
            top: size.height * orb.top - (scrollY * parallax),
            left: size.width * orb.left,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                width: orb.size,
                height: orb.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [orb.color, Colors.transparent],
                    stops: const [0.0, 0.68],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
