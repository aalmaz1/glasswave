import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/app_themes.dart';

/// Фоновый градиент с орбами и parallax-эффектом
class GradientBackground extends StatefulWidget {
  final AppTheme theme;
  final Widget child;
  final double scrollOffset;
  
  const GradientBackground({
    super.key,
    required this.theme,
    required this.child,
    this.scrollOffset = 0,
  });
  
  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: widget.theme.gradient,
          ),
        ),
        
        // Orbs with parallax
        ...widget.theme.orbs.asMap().entries.map((entry) {
          final index = entry.key;
          final orb = entry.value;
          return _Orb(
            orb: orb,
            scrollOffset: widget.scrollOffset,
            parallaxFactor: 0.07 * (index + 1),
          );
        }),
        
        // Content
        widget.child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final OrbConfig orb;
  final double scrollOffset;
  final double parallaxFactor;
  
  const _Orb({
    required this.orb,
    required this.scrollOffset,
    required this.parallaxFactor,
  });
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Parallax offset
    final offsetY = scrollOffset * parallaxFactor;
    
    // Random position based on orb properties
    final positions = [
      Offset(size.width * 0.2, -orb.radius * 0.3 + offsetY),
      Offset(size.width * 0.8, size.height * 0.3 + offsetY),
      Offset(size.width * 0.3, size.height * 0.6 + offsetY),
      Offset(size.width * 0.7, size.height * 0.1 + offsetY),
    ];
    
    final position = positions[orb.radius.hashCode % positions.length];
    
    return Positioned(
      left: position.dx - orb.radius,
      top: position.dy - orb.radius,
      child: BlurCircle(
        radius: orb.radius,
        color: orb.color,
      ),
    );
  }
}

/// Размытый круг (орб)
class BlurCircle extends StatelessWidget {
  final double radius;
  final Color color;
  
  const BlurCircle({
    super.key,
    required this.radius,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// Holographic sheen overlay для карточек
class HolographicSheen extends StatelessWidget {
  const HolographicSheen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
      ),
    );
  }
}
