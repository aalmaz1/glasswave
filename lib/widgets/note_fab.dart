import 'package:flutter/material.dart';
import '../utils/glass_style.dart';

/// FAB (кнопка "+") с глассморфизмом
class NoteFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const NoteFAB({super.key, required this.onPressed});

  @override
  State<NoteFAB> createState() => _NoteFABState();
}

class _NoteFABState extends State<NoteFAB> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1280;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Size and position
    final size = isDesktop ? 56.0 : 52.0;
    final bottom = isDesktop ? 32.0 : (88.0 + bottomPadding);
    final right = isDesktop ? 32.0 : 20.0;

    return Positioned(
      right: right,
      bottom: bottom,
      child: MouseRegion(
        onEnter: (_) => isDesktop ? setState(() => _isHovered = true) : null,
        onExit: (_) => isDesktop ? setState(() => _isHovered = false) : null,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: GlassContainer(
              borderRadius: 16,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : GlassStyle.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.4)
                        : GlassStyle.border,
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
