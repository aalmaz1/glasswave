import 'package:flutter/material.dart';

/// Орб - цветной размытый круг на фоне темы
class Orb {
  final String color; // hex color
  final double size;
  final double top; // percentage
  final double left; // percentage

  const Orb({
    required this.color,
    required this.size,
    required this.top,
    required this.left,
  });

  Color get colorValue => _hexToColor(color);

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex += 'FF';
    return Color(int.parse(hex, radix: 16));
  }
}

/// Тема приложения с градиентом фона, орбами и акцентами
class AppTheme {
  final String id;
  final String name;
  final String emoji;
  final List<String> bg; // градиент фона (2-5 цветов hex)
  final List<Orb> orbs;
  final List<String> accents;

  const AppTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bg,
    required this.orbs,
    required this.accents,
  });

  /// Градиент фона с поддержкой до 5 остановок (как в Figma)
  /// Для совместимости: если 2 цвета - используется простой градиент
  /// Если 5 цветов - используется расширенный градиент с stops
  LinearGradient get bgGradient {
    final colors = bg.map((c) => _hexToColor(c)).toList();
    if (colors.length == 5) {
      return LinearGradient(
        colors: colors,
        stops: [0.0, 0.28, 0.52, 0.75, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex += 'FF';
    return Color(int.parse(hex, radix: 16));
  }

  List<Color> get accentColors =>
      accents.map((c) => _hexToColor(c)).toList();
}

/// Все 12 тем приложения (теперь 13 с Figma темой)
class Themes {
  static const List<AppTheme> all = [
    sunsetTheme,
    iceTheme,
    monoTheme,
    cyberTheme,
    auroraTheme,
    roseTheme,
    cosmosTheme,
    forestTheme,
    obsidianTheme,
    graphiteTheme,
    midnightTheme,
    espressoTheme,
    figmaTheme, // Новая тема из Figma
  ];

  static const sunsetTheme = AppTheme(
    id: 'sunset',
    name: 'Закат',
    emoji: '🌅',
    bg: ['#ff6b35', '#f7c59f'],
    orbs: [
      Orb(color: '#ffecd2', size: 300, top: 10, left: 20),
      Orb(color: '#f7c59f', size: 200, top: 60, left: 70),
      Orb(color: '#ff6b35', size: 250, top: 40, left: 50),
    ],
    accents: ['#ff6b35', '#f7c59f', '#ffecd2', '#ffa07a'],
  );

  static const iceTheme = AppTheme(
    id: 'ice',
    name: 'Лёд',
    emoji: '🧊',
    bg: ['#e0f7fa', '#80deea'],
    orbs: [
      Orb(color: '#b2ebf2', size: 280, top: 15, left: 25),
      Orb(color: '#4dd0e1', size: 220, top: 55, left: 65),
      Orb(color: '#26c6da', size: 260, top: 35, left: 45),
    ],
    accents: ['#00bcd4', '#4dd0e1', '#b2ebf2', '#80deea'],
  );

  static const monoTheme = AppTheme(
    id: 'mono',
    name: 'Моно',
    emoji: '⚫',
    bg: ['#424242', '#9e9e9e'],
    orbs: [
      Orb(color: '#616161', size: 300, top: 20, left: 30),
      Orb(color: '#757575', size: 200, top: 60, left: 70),
      Orb(color: '#bdbdbd', size: 250, top: 40, left: 50),
    ],
    accents: ['#424242', '#757575', '#bdbdbd', '#9e9e9e'],
  );

  static const cyberTheme = AppTheme(
    id: 'cyber',
    name: 'Кибер',
    emoji: '🤖',
    bg: ['#0d0d0d', '#1a1a2e'],
    orbs: [
      Orb(color: '#0f3460', size: 320, top: 10, left: 20),
      Orb(color: '#e94560', size: 180, top: 65, left: 75),
      Orb(color: '#16213e', size: 280, top: 45, left: 55),
    ],
    accents: ['#e94560', '#0f3460', '#16213e', '#533483'],
  );

  static const auroraTheme = AppTheme(
    id: 'aurora',
    name: 'Аврора',
    emoji: '🌌',
    bg: ['#134e5e', '#71b280'],
    orbs: [
      Orb(color: '#0d7377', size: 290, top: 18, left: 22),
      Orb(color: '#14a3a8', size: 210, top: 58, left: 68),
      Orb(color: '#2ec4b6', size: 270, top: 38, left: 48),
    ],
    accents: ['#0d7377', '#14a3a8', '#2ec4b6', '#71b280'],
  );

  static const roseTheme = AppTheme(
    id: 'rose',
    name: 'Роза',
    emoji: '🌹',
    bg: ['#ffeef8', '#ffafbd'],
    orbs: [
      Orb(color: '#ffc3a0', size: 270, top: 12, left: 28),
      Orb(color: '#ff9a9e', size: 190, top: 62, left: 72),
      Orb(color: '#fad0c4', size: 240, top: 42, left: 52),
    ],
    accents: ['#ff9a9e', '#ffc3a0', '#fad0c4', '#ffafbd'],
  );

  static const cosmosTheme = AppTheme(
    id: 'cosmos',
    name: 'Космос',
    emoji: '🌠',
    bg: ['#0f0c29', '#302b63'],
    orbs: [
      Orb(color: '#24243e', size: 310, top: 14, left: 24),
      Orb(color: '#533483', size: 200, top: 64, left: 74),
      Orb(color: '#1a1a2e', size: 260, top: 44, left: 54),
    ],
    accents: ['#533483', '#24243e', '#1a1a2e', '#6a0dad'],
  );

  static const forestTheme = AppTheme(
    id: 'forest',
    name: 'Лес',
    emoji: '🌲',
    bg: ['#134e5e', '#71b280'],
    orbs: [
      Orb(color: '#0d5c4e', size: 285, top: 16, left: 26),
      Orb(color: '#2d8b6e', size: 205, top: 56, left: 66),
      Orb(color: '#4caf50', size: 255, top: 36, left: 46),
    ],
    accents: ['#0d5c4e', '#2d8b6e', '#4caf50', '#71b280'],
  );

  static const obsidianTheme = AppTheme(
    id: 'obsidian',
    name: 'Обсидиан',
    emoji: '🖤',
    bg: ['#000000', '#434343'],
    orbs: [
      Orb(color: '#1a1a1a', size: 300, top: 19, left: 29),
      Orb(color: '#2a2a2a', size: 210, top: 59, left: 69),
      Orb(color: '#3a3a3a', size: 250, top: 39, left: 49),
    ],
    accents: ['#1a1a1a', '#2a2a2a', '#3a3a3a', '#434343'],
  );

  static const graphiteTheme = AppTheme(
    id: 'graphite',
    name: 'Графит',
    emoji: '✏️',
    bg: ['#2c3e50', '#4ca1af'],
    orbs: [
      Orb(color: '#34495e', size: 295, top: 17, left: 27),
      Orb(color: '#5d6d7e', size: 215, top: 57, left: 67),
      Orb(color: '#7f8c8d', size: 265, top: 37, left: 47),
    ],
    accents: ['#34495e', '#5d6d7e', '#7f8c8d', '#4ca1af'],
  );

  static const midnightTheme = AppTheme(
    id: 'midnight',
    name: 'Полночь',
    emoji: '🌙',
    bg: ['#141e30', '#243b55'],
    orbs: [
      Orb(color: '#1f2833', size: 288, top: 13, left: 23),
      Orb(color: '#2c3e50', size: 208, top: 63, left: 73),
      Orb(color: '#34495e', size: 258, top: 43, left: 53),
    ],
    accents: ['#1f2833', '#2c3e50', '#34495e', '#243b55'],
  );

  static const espressoTheme = AppTheme(
    id: 'espresso',
    name: 'Эспрессо',
    emoji: '☕',
    bg: ['#3e2723', '#6d4c41'],
    orbs: [
      Orb(color: '#4e342e', size: 292, top: 11, left: 21),
      Orb(color: '#5d4037', size: 212, top: 61, left: 71),
      Orb(color: '#795548', size: 262, top: 41, left: 51),
    ],
    accents: ['#4e342e', '#5d4037', '#795548', '#6d4c41'],
  );

  /// Тема Figma с 5-ступенчатым градиентом (как в оригинале)
  /// rgb(19, 5, 0) -> rgb(46, 12, 0) -> rgb(74, 20, 0) -> rgb(107, 30, 0) -> rgb(138, 40, 0)
  static const figmaTheme = AppTheme(
    id: 'figma',
    name: 'Figma',
    emoji: '🎨',
    bg: ['#130500', '#2E0C00', '#4A1400', '#6B1E00', '#8A2800'],
    orbs: [
      Orb(color: '#FF8C42', size: 280, top: 15, left: 20),
      Orb(color: '#FF6B35', size: 220, top: 60, left: 70),
      Orb(color: '#FFA07A', size: 260, top: 40, left: 50),
    ],
    accents: ['#FF8C42', '#FF6B35', '#FFA07A', '#F7C59F'],
  );

  static AppTheme getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => sunsetTheme);
  }
}
