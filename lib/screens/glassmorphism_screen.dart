import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Главный экран с эффектом Glassmorphism
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Контроллеры анимации для каждого орба
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;

  // Позиции орбов
  double _orb1X = -50;
  double _orb1Y = -50;
  double _orb2X = 300;
  double _orb2Y = -80;
  double _orb3X = -100;
  double _orb3Y = 400;
  double _orb4X = 350;
  double _orb4Y = 500;

  @override
  void initState() {
    super.initState();

    // Инициализация контроллеров анимации
    _controller1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _controller4 = AnimationController(
      duration: const Duration(seconds: 9),
      vsync: this,
    )..repeat(reverse: true);

    // Запуск анимации позиций
    _startOrbAnimations();
  }

  void _startOrbAnimations() {
    // Анимация первого орба
    _controller1.addListener(() {
      setState(() {
        _orb1X = -50 + sin(_controller1.value * 2 * pi) * 150;
        _orb1Y = -50 + cos(_controller1.value * 2 * pi) * 100;
      });
    });

    // Анимация второго орба
    _controller2.addListener(() {
      setState(() {
        _orb2X = 300 + cos(_controller2.value * 2 * pi) * 120;
        _orb2Y = -80 + sin(_controller2.value * 2 * pi) * 150;
      });
    });

    // Анимация третьего орба
    _controller3.addListener(() {
      setState(() {
        _orb3X = -100 + sin(_controller3.value * 2 * pi + pi / 3) * 180;
        _orb3Y = 400 + cos(_controller3.value * 2 * pi + pi / 3) * 120;
      });
    });

    // Анимация четвертого орба
    _controller4.addListener(() {
      setState(() {
        _orb4X = 350 + cos(_controller4.value * 2 * pi + pi / 4) * 140;
        _orb4Y = 500 + sin(_controller4.value * 2 * pi + pi / 4) * 100;
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Градиентный фон от #130500 до #8A2800 под углом 145°
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF130500), // Тёмно-красный
                  Color(0xFF8A2800), // Насыщенный оранжевый
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // Размытые орбы (круги) с анимацией
          Positioned(
            left: _orb1X,
            top: _orb1Y,
            child: _buildOrb(200),
          ),
          Positioned(
            left: _orb2X,
            top: _orb2Y,
            child: _buildOrb(250),
          ),
          Positioned(
            left: _orb3X,
            top: _orb3Y,
            child: _buildOrb(180),
          ),
          Positioned(
            left: _orb4X,
            top: _orb4Y,
            child: _buildOrb(220),
          ),

          // Центрированная стеклянная карточка
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassCard(),
            ),
          ),
        ],
      ),
    );
  }

  /// Виджет размытого орба
  Widget _buildOrb(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF8C42).withOpacity(0.22), // Оранжевый с opacity 0.22
      ),
    );
  }
}

/// Стеклянная карточка с эффектом Glassmorphism
class GlassCard extends StatelessWidget {
  const GlassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      // ClipRRect необходим для ограничения размытия пределами карточки
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // BackdropFilter для размытия фона (sigma 24px)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                // Фон карточки: белый с прозрачностью 6%
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  // Рамка: 1px белая с прозрачностью 20%
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                    width: 1,
                  ),
                  // Тень: чёрная с прозрачностью 50%, смещение Y=10, размытие=40
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.50),
                      offset: const Offset(0, 10),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // Слой "стеклянного кольца" - градиент от верхнего левого к нижнему правому
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.35), // Начало
                    Colors.white.withOpacity(0.08), // 40%
                    Colors.white.withOpacity(0.02), // Конец
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Слой общего отблеска - градиент от верхнего левого к нижнему правому
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.06), // Начало
                    Colors.transparent, // Середина
                    Colors.white.withOpacity(0.03), // Конец
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Контент карточки
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Иконка звезды
                  Icon(
                    Icons.star,
                    size: 48,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  // Текст приветствия
                  Text(
                    'Привет, это стекло!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Дополнительный текст
                  Text(
                    'Эффект матового стекла с размытием фона',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
