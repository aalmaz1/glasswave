import 'package:flutter/material.dart';

/// Акцентные цвета для каждой темы (4 варианта на тему, очень слабые opacity)
class AccentColors {
  final List<Color> colors;

  const AccentColors(this.colors);

  // Тёплый закат
  static const sunset = AccentColors([
    Color.fromRGBO(255, 150, 50, 0.09),
    Color.fromRGBO(255, 90, 30, 0.08),
    Color.fromRGBO(255, 120, 40, 0.07),
    Color.fromRGBO(255, 100, 35, 0.08),
  ]);

  // Ледяная свежесть
  static const ice = AccentColors([
    Color.fromRGBO(0, 180, 230, 0.09),
    Color.fromRGBO(60, 210, 220, 0.08),
    Color.fromRGBO(0, 160, 210, 0.07),
    Color.fromRGBO(40, 190, 220, 0.08),
  ]);

  // Монохром
  static const mono = AccentColors([
    Color.fromRGBO(200, 200, 220, 0.07),
    Color.fromRGBO(180, 180, 200, 0.06),
    Color.fromRGBO(220, 220, 240, 0.06),
    Color.fromRGBO(190, 190, 210, 0.07),
  ]);

  // Кибер-закат
  static const cyber = AccentColors([
    Color.fromRGBO(0, 220, 200, 0.09),
    Color.fromRGBO(200, 30, 90, 0.08),
    Color.fromRGBO(0, 200, 180, 0.07),
    Color.fromRGBO(180, 25, 80, 0.08),
  ]);

  // Северное сияние
  static const aurora = AccentColors([
    Color.fromRGBO(0, 240, 120, 0.09),
    Color.fromRGBO(60, 30, 230, 0.08),
    Color.fromRGBO(0, 220, 100, 0.07),
    Color.fromRGBO(50, 25, 210, 0.08),
  ]);

  // Полночная роза
  static const rose = AccentColors([
    Color.fromRGBO(230, 0, 80, 0.09),
    Color.fromRGBO(150, 0, 200, 0.08),
    Color.fromRGBO(210, 0, 70, 0.07),
    Color.fromRGBO(140, 0, 180, 0.08),
  ]);

  // Глубокий космос
  static const cosmos = AccentColors([
    Color.fromRGBO(110, 0, 255, 0.09),
    Color.fromRGBO(180, 60, 255, 0.08),
    Color.fromRGBO(100, 0, 235, 0.07),
    Color.fromRGBO(170, 50, 240, 0.08),
  ]);

  // Тёмный лес
  static const forest = AccentColors([
    Color.fromRGBO(0, 190, 55, 0.09),
    Color.fromRGBO(40, 210, 70, 0.08),
    Color.fromRGBO(0, 170, 45, 0.07),
    Color.fromRGBO(35, 190, 60, 0.08),
  ]);

  // Обсидиан
  static const obsidian = AccentColors([
    Color.fromRGBO(40, 60, 140, 0.09),
    Color.fromRGBO(20, 40, 100, 0.08),
    Color.fromRGBO(35, 55, 130, 0.07),
    Color.fromRGBO(30, 50, 120, 0.08),
  ]);

  // Графит
  static const graphite = AccentColors([
    Color.fromRGBO(180, 185, 210, 0.07),
    Color.fromRGBO(140, 145, 175, 0.06),
    Color.fromRGBO(160, 165, 190, 0.06),
    Color.fromRGBO(150, 155, 180, 0.07),
  ]);

  // Полночь
  static const midnight = AccentColors([
    Color.fromRGBO(30, 50, 160, 0.09),
    Color.fromRGBO(50, 70, 190, 0.08),
    Color.fromRGBO(25, 45, 150, 0.07),
    Color.fromRGBO(45, 65, 180, 0.08),
  ]);

  // Эспрессо
  static const espresso = AccentColors([
    Color.fromRGBO(160, 80, 10, 0.09),
    Color.fromRGBO(200, 120, 20, 0.08),
    Color.fromRGBO(150, 70, 10, 0.07),
    Color.fromRGBO(180, 100, 15, 0.08),
  ]);

  static List<AccentColors> get all => [
        sunset,
        ice,
        mono,
        cyber,
        aurora,
        rose,
        cosmos,
        forest,
        obsidian,
        graphite,
        midnight,
        espresso,
      ];
}

/// Определение темы с градиентом фона и орбами
class AppTheme {
  final int id;
  final String name;
  final String emoji;
  final LinearGradient bgGradient;
  final List<OrbDefinition> orbs;
  final AccentColors accentColors;

  const AppTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgGradient,
    required this.orbs,
    required this.accentColors,
  });

  /// Получить цвет акцента по индексу
  Color getAccentColor(int idx) {
    if (idx < 0 || idx >= accentColors.colors.length) {
      return accentColors.colors.first;
    }
    return accentColors.colors[idx];
  }

  static const List<AppTheme> themes = [
    // A. Тёплый закат 🌅
    AppTheme(
      id: 0,
      name: 'Тёплый закат',
      emoji: '🌅',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 145 * 3.14159 / 180,
        colors: [
          Color(0xFF130500),
          Color(0xFF2E0C00),
          Color(0xFF4A1400),
          Color(0xFF8A2800),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(255, 110, 20, 0.22), radius: 340),
        OrbDefinition(color: Color.fromRGBO(180, 30, 40, 0.18), radius: 260),
      ],
      accentColors: AccentColors.sunset,
    ),
    // B. Ледяная свежесть 🧊
    AppTheme(
      id: 1,
      name: 'Ледяная свежесть',
      emoji: '🧊',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 145 * 3.14159 / 180,
        colors: [
          Color(0xFF00080F),
          Color(0xFF001525),
          Color(0xFF002440),
          Color(0xFF004870),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(0, 180, 230, 0.18), radius: 320),
        OrbDefinition(color: Color.fromRGBO(60, 210, 220, 0.09), radius: 240),
      ],
      accentColors: AccentColors.ice,
    ),
    // C. Монохром 🪨
    AppTheme(
      id: 2,
      name: 'Монохром',
      emoji: '🪨',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 150 * 3.14159 / 180,
        colors: [
          Color(0xFF0E0E10),
          Color(0xFF141416),
          Color(0xFF1A1A1C),
          Color(0xFF111113),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(200, 200, 220, 0.07), radius: 300),
        OrbDefinition(color: Color.fromRGBO(180, 180, 200, 0.05), radius: 220),
      ],
      accentColors: AccentColors.mono,
    ),
    // D. Кибер-закат 🌺
    AppTheme(
      id: 3,
      name: 'Кибер-закат',
      emoji: '🌺',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 140 * 3.14159 / 180,
        colors: [
          Color(0xFF001212),
          Color(0xFF002828),
          Color(0xFF004040),
          Color(0xFF380A20),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(0, 220, 200, 0.20), radius: 330),
        OrbDefinition(color: Color.fromRGBO(200, 30, 90, 0.18), radius: 250),
      ],
      accentColors: AccentColors.cyber,
    ),
    // E. Северное сияние 🌌
    AppTheme(
      id: 4,
      name: 'Северное сияние',
      emoji: '🌌',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 155 * 3.14159 / 180,
        colors: [
          Color(0xFF010806),
          Color(0xFF031A0E),
          Color(0xFF051828),
          Color(0xFF06041A),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(0, 240, 120, 0.18), radius: 310),
        OrbDefinition(color: Color.fromRGBO(60, 30, 230, 0.20), radius: 270),
      ],
      accentColors: AccentColors.aurora,
    ),
    // F. Полночная роза 🥀
    AppTheme(
      id: 5,
      name: 'Полночная роза',
      emoji: '🥀',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 145 * 3.14159 / 180,
        colors: [
          Color(0xFF0A0005),
          Color(0xFF180008),
          Color(0xFF260010),
          Color(0xFF0E000C),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(230, 0, 80, 0.22), radius: 340),
        OrbDefinition(color: Color.fromRGBO(150, 0, 200, 0.17), radius: 260),
      ],
      accentColors: AccentColors.rose,
    ),
    // G. Глубокий космос 🔭
    AppTheme(
      id: 6,
      name: 'Глубокий космос',
      emoji: '🔭',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 148 * 3.14159 / 180,
        colors: [
          Color(0xFF020008),
          Color(0xFF08001E),
          Color(0xFF110030),
          Color(0xFF030010),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(110, 0, 255, 0.20), radius: 350),
        OrbDefinition(color: Color.fromRGBO(180, 60, 255, 0.09), radius: 230),
      ],
      accentColors: AccentColors.cosmos,
    ),
    // H. Тёмный лес 🌲
    AppTheme(
      id: 7,
      name: 'Тёмный лес',
      emoji: '🌲',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 145 * 3.14159 / 180,
        colors: [
          Color(0xFF010602),
          Color(0xFF030E05),
          Color(0xFF061808),
          Color(0xFF040C06),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(0, 190, 55, 0.17), radius: 320),
        OrbDefinition(color: Color.fromRGBO(40, 210, 70, 0.08), radius: 240),
      ],
      accentColors: AccentColors.forest,
    ),
    // I. Обсидиан 🪬
    AppTheme(
      id: 8,
      name: 'Обсидиан',
      emoji: '🪬',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 158 * 3.14159 / 180,
        colors: [
          Color(0xFF08080C),
          Color(0xFF0C0C12),
          Color(0xFF090B10),
          Color(0xFF07070A),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(40, 60, 140, 0.22), radius: 400),
        OrbDefinition(color: Color.fromRGBO(20, 40, 100, 0.16), radius: 310),
      ],
      accentColors: AccentColors.obsidian,
    ),
    // J. Графит 🩶
    AppTheme(
      id: 9,
      name: 'Графит',
      emoji: '🩶',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 152 * 3.14159 / 180,
        colors: [
          Color(0xFF111113),
          Color(0xFF161618),
          Color(0xFF191919),
          Color(0xFF111112),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(180, 185, 210, 0.10), radius: 375),
        OrbDefinition(color: Color.fromRGBO(140, 145, 175, 0.07), radius: 280),
      ],
      accentColors: AccentColors.graphite,
    ),
    // K. Полночь 🌑
    AppTheme(
      id: 10,
      name: 'Полночь',
      emoji: '🌑',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 148 * 3.14159 / 180,
        colors: [
          Color(0xFF040610),
          Color(0xFF080C1C),
          Color(0xFF0C1028),
          Color(0xFF040610),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(30, 50, 160, 0.25), radius: 360),
        OrbDefinition(color: Color.fromRGBO(50, 70, 190, 0.10), radius: 200),
      ],
      accentColors: AccentColors.midnight,
    ),
    // L. Эспрессо ☕
    AppTheme(
      id: 11,
      name: 'Эспрессо',
      emoji: '☕',
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        rotation: 150 * 3.14159 / 180,
        colors: [
          Color(0xFF0E0804),
          Color(0xFF160C05),
          Color(0xFF1C1008),
          Color(0xFF0D0703),
        ],
      ),
      orbs: [
        OrbDefinition(color: Color.fromRGBO(160, 80, 10, 0.22), radius: 350),
        OrbDefinition(color: Color.fromRGBO(200, 120, 20, 0.08), radius: 190),
      ],
      accentColors: AccentColors.espresso,
    ),
  ];

  static AppTheme getById(int id) {
    if (id < 0 || id >= themes.length) return themes.first;
    return themes[id];
  }
}

/// Определение декоративного орба
class OrbDefinition {
  final Color color;
  final double radius;

  const OrbDefinition({
    required this.color,
    required this.radius,
  });
}
