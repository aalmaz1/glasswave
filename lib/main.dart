import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/theme_data.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация провайдера
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const NoovaNotesApp(),
    ),
  );
}

class NoovaNotesApp extends StatelessWidget {
  const NoovaNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appState, child) {
        final theme = appState.currentTheme;
        
        return MaterialApp(
          title: 'Noova Notes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
          ),
          home: GlassBackground(
            theme: theme,
            child: const DashboardScreen(),
          ),
        );
      },
    );
  }
}

/// Фон с градиентом и анимированными орбами
class GlassBackground extends StatefulWidget {
  final Widget child;
  final AppTheme theme;

  const GlassBackground({
    super.key,
    required this.child,
    required this.theme,
  });

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _orbAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Создаём анимации для каждого орба
    _orbAnimations = widget.theme.orbs.map((orb) {
      return Tween<Offset>(
        begin: Offset(
          (orb.left / 100 - 0.5) * 0.3,
          (orb.top / 100 - 0.5) * 0.3,
        ),
        end: Offset(
          (orb.left / 100 - 0.5) * 0.3 + 0.1,
          (orb.top / 100 - 0.5) * 0.3 + 0.1,
        ),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.theme.orbs.indexOf(orb) / widget.theme.orbs.length,
          1.0,
        ),
      ));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Градиентный фон
        Container(
          decoration: BoxDecoration(
            gradient: widget.theme.bgGradient,
          ),
        ),
        // Анимированные орбы
        ...List.generate(widget.theme.orbs.length, (index) {
          final orb = widget.theme.orbs[index];
          return AnimatedBuilder(
            animation: _orbAnimations[index],
            builder: (context, child) {
              return FractionalTranslation(
                translation: _orbAnimations[index].value,
                child: Positioned(
                  left: orb.left / 100 * MediaQuery.of(context).size.width -
                      orb.size / 2,
                  top: orb.top / 100 * MediaQuery.of(context).size.height -
                      orb.size / 2,
                  child: Container(
                    width: orb.size,
                    height: orb.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          orb.colorValue.withOpacity(0.22),
                          orb.colorValue.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Размытие фона для орбов
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(),
        ),
        // Контент приложения
        widget.child,
      ],
    );
  }
}
