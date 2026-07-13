import 'package:flutter/material.dart';

/// CustomPainter для градиентной рамки карточки (1px сверху)
class GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    
    // Градиент для рамки: white 35% → white with 8% opacity 40% → white with 2% opacity 100%
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      rotation: 160 * 3.14159 / 180,
      colors: [
        const Color(0xFFFFFFFF),           // white 100%
        const Color(0xFFFFFFFF).withOpacity(0.35), // white 35%
        const Color(0x1AFFFFFF),           // white ~8%
        const Color(0x05FFFFFF),           // white ~2%
      ],
      stops: const [0.0, 0.35, 0.40, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter для голографического блеска поверх карточки
class HolographicSheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      rotation: 45 * 3.14159 / 180,
      colors: [
        const Color(0x0AFFFFFF), // white ~6%
        Colors.transparent,
        const Color(0x08FFFFFF), // white ~3%
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.overlay;
    
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Виджет стеклянной карточки с полным глассморфизмом
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isHovered;
  final Color? accentColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.onTap,
    this.isHovered = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0, isHovered ? -6 : 0)
            ..scale(isHovered ? 1.02 : 1.0),
          child: Stack(
            children: [
              // Основной контейнер с глассморфизмом
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: const Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
                  border: Border.all(
                    color: isHovered 
                        ? const Color(0x66FFFFFF) // rgba(255,255,255,0.40) при hover
                        : const Color(0x33FFFFFF), // rgba(255,255,255,0.20)
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x80000000),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                    // Inner glow сверху
                    BoxShadow(
                      color: const Color(0x26FFFFFF), // rgba(255,255,255,0.15)
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Stack(
                      children: [
                        // Акцентный градиент (очень слабый)
                        if (accentColor != null)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                rotation: 145 * 3.14159 / 180,
                                colors: [
                                  accentColor!,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        // Контент
                        child,
                        // Голографический блеск
                        CustomPaint(
                          painter: HolographicSheenPainter(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Градиентная рамка поверх всего
              Positioned.fill(
                child: CustomPaint(
                  painter: GradientBorderPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет стеклянной кнопки/чипса
class GlassChip extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool isActive;
  final Color? backgroundColor;

  const GlassChip({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
    this.isActive = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor ?? const Color(0x0FFFFFFF),
            border: Border.all(
              color: isActive 
                  ? const Color(0x66FFFFFF)
                  : const Color(0x33FFFFFF),
              width: 1,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Виджет стеклянной панели поиска
class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSort;
  final bool hasActiveSort;
  final VoidCallback? onSettings;
  final String hintText;

  const GlassSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onSort,
    this.hasActiveSort = false,
    this.onSettings,
    this.hintText = 'Поиск по заметкам…',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0x0FFFFFFF),
        border: Border.all(
          color: const Color(0x33FFFFFF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x80000000),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Иконка поиска
              Icon(
                Icons.search_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              // Поле ввода
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              // Кнопка очистки
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 18,
                    ),
                  ),
                ),
              // Разделитель
              Container(
                height: 24,
                width: 1,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // Кнопка сортировки
              GestureDetector(
                onTap: onSort,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.sliders_rounded,
                        color: hasActiveSort 
                            ? const Color(0xFFFFB74D) // янтарный когда активна
                            : Colors.white.withOpacity(0.5),
                        size: 22,
                      ),
                      if (hasActiveSort)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB74D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Кнопка настроек
              GestureDetector(
                onTap: onSettings,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
