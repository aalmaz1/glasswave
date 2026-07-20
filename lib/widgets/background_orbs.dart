import 'package:flutter/material.dart';
import '../theme/app_theme_data.dart';

class BackgroundOrbs extends StatelessWidget {
  final AppThemeData theme;
  final double scrollY;

  const BackgroundOrbs({super.key, required this.theme, this.scrollY = 0});

  @override
  Widget build(BuildContext context) {
    final parallaxCoefficients = [0.07, 0.15, 0.22];
    return Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: theme.bg)),
        ...theme.orbs.asMap().entries.map((entry) {
          int i = entry.key;
          OrbData orb = entry.value;
          double parallax = parallaxCoefficients[i % parallaxCoefficients.length];
          return Positioned(
            top: MediaQuery.of(context).size.height * orb.top - (scrollY * parallax),
            left: MediaQuery.of(context).size.width * orb.left,
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
          );
        }),
      ],
    );
  }
}
