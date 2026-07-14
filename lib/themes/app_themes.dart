import 'package:flutter/material.dart';

/// 12 Premium Themes with gradients and orbs
class AppTheme {
  final String id;
  final String name;
  final String emoji;
  final List<Color> gradientColors;
  final List<OrbConfig> orbs;
  final List<Color> accentColors;

  const AppTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.orbs,
    required this.accentColors,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      );

  static const List<AppTheme> all = [
    sunset,
    iceFresh,
    monochrome,
    cyberSunset,
    aurora,
    midnightRose,
    deepSpace,
    darkForest,
    obsidian,
    graphite,
    midnight,
    espresso,
  ];

  // A. Тёплый закат 🌅
  static const sunset = AppTheme(
    id: 'sunset',
    name: 'Тёплый закат',
    emoji: '🌅',
    gradientColors: [
      Color(0xFF130500),
      Color(0xFF2E0C00),
      Color(0xFF4A1400),
      Color(0xFF8A2800),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(255, 110, 20, 0.22), radius: 340),
      OrbConfig(color: Color.fromRGBO(180, 30, 40, 0.18), radius: 260),
    ],
    accentColors: [
      Color.fromRGBO(255, 150, 50, 0.09),
      Color.fromRGBO(255, 90, 30, 0.08),
      Color.fromRGBO(255, 120, 40, 0.07),
      Color.fromRGBO(255, 80, 25, 0.06),
    ],
  );

  // B. Ледяная свежесть 🧊
  static const iceFresh = AppTheme(
    id: 'ice_fresh',
    name: 'Ледяная свежесть',
    emoji: '🧊',
    gradientColors: [
      Color(0xFF00080F),
      Color(0xFF001525),
      Color(0xFF002440),
      Color(0xFF004870),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(0, 180, 230, 0.18), radius: 320),
      OrbConfig(color: Color.fromRGBO(60, 210, 220, 0.09), radius: 240),
    ],
    accentColors: [
      Color.fromRGBO(0, 180, 230, 0.09),
      Color.fromRGBO(60, 210, 220, 0.08),
      Color.fromRGBO(30, 195, 225, 0.07),
      Color.fromRGBO(20, 170, 200, 0.06),
    ],
  );

  // C. Монохром 🪨
  static const monochrome = AppTheme(
    id: 'monochrome',
    name: 'Монохром',
    emoji: '🪨',
    gradientColors: [
      Color(0xFF0E0E10),
      Color(0xFF141416),
      Color(0xFF1A1A1C),
      Color(0xFF111113),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(200, 200, 220, 0.07), radius: 300),
      OrbConfig(color: Color.fromRGBO(180, 180, 200, 0.05), radius: 220),
    ],
    accentColors: [
      Color.fromRGBO(200, 200, 220, 0.08),
      Color.fromRGBO(180, 180, 200, 0.07),
      Color.fromRGBO(160, 160, 180, 0.06),
      Color.fromRGBO(140, 140, 160, 0.05),
    ],
  );

  // D. Кибер-закат 🌺
  static const cyberSunset = AppTheme(
    id: 'cyber_sunset',
    name: 'Кибер-закат',
    emoji: '🌺',
    gradientColors: [
      Color(0xFF001212),
      Color(0xFF002828),
      Color(0xFF004040),
      Color(0xFF380A20),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(0, 220, 200, 0.20), radius: 330),
      OrbConfig(color: Color.fromRGBO(200, 30, 90, 0.18), radius: 250),
    ],
    accentColors: [
      Color.fromRGBO(0, 220, 200, 0.09),
      Color.fromRGBO(200, 30, 90, 0.08),
      Color.fromRGBO(100, 210, 180, 0.07),
      Color.fromRGBO(180, 40, 80, 0.06),
    ],
  );

  // E. Северное сияние 🌌
  static const aurora = AppTheme(
    id: 'aurora',
    name: 'Северное сияние',
    emoji: '🌌',
    gradientColors: [
      Color(0xFF010806),
      Color(0xFF031A0E),
      Color(0xFF051828),
      Color(0xFF06041A),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(0, 240, 120, 0.18), radius: 310),
      OrbConfig(color: Color.fromRGBO(60, 30, 230, 0.20), radius: 270),
    ],
    accentColors: [
      Color.fromRGBO(0, 240, 120, 0.09),
      Color.fromRGBO(60, 30, 230, 0.08),
      Color.fromRGBO(30, 220, 140, 0.07),
      Color.fromRGBO(80, 50, 200, 0.06),
    ],
  );

  // F. Полночная роза 🥀
  static const midnightRose = AppTheme(
    id: 'midnight_rose',
    name: 'Полночная роза',
    emoji: '🥀',
    gradientColors: [
      Color(0xFF0A0005),
      Color(0xFF180008),
      Color(0xFF260010),
      Color(0xFF0E000C),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(230, 0, 80, 0.22), radius: 340),
      OrbConfig(color: Color.fromRGBO(150, 0, 200, 0.17), radius: 260),
    ],
    accentColors: [
      Color.fromRGBO(230, 0, 80, 0.09),
      Color.fromRGBO(150, 0, 200, 0.08),
      Color.fromRGBO(200, 20, 100, 0.07),
      Color.fromRGBO(130, 10, 180, 0.06),
    ],
  );

  // G. Глубокий космос 🔭
  static const deepSpace = AppTheme(
    id: 'deep_space',
    name: 'Глубокий космос',
    emoji: '🔭',
    gradientColors: [
      Color(0xFF020008),
      Color(0xFF08001E),
      Color(0xFF110030),
      Color(0xFF030010),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(110, 0, 255, 0.20), radius: 350),
      OrbConfig(color: Color.fromRGBO(180, 60, 255, 0.09), radius: 270),
    ],
    accentColors: [
      Color.fromRGBO(110, 0, 255, 0.09),
      Color.fromRGBO(180, 60, 255, 0.08),
      Color.fromRGBO(145, 30, 230, 0.07),
      Color.fromRGBO(95, 20, 200, 0.06),
    ],
  );

  // H. Тёмный лес 🌲
  static const darkForest = AppTheme(
    id: 'dark_forest',
    name: 'Тёмный лес',
    emoji: '🌲',
    gradientColors: [
      Color(0xFF010602),
      Color(0xFF030E05),
      Color(0xFF061808),
      Color(0xFF040C06),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(0, 190, 55, 0.17), radius: 320),
      OrbConfig(color: Color.fromRGBO(40, 210, 70, 0.08), radius: 240),
    ],
    accentColors: [
      Color.fromRGBO(0, 190, 55, 0.09),
      Color.fromRGBO(40, 210, 70, 0.08),
      Color.fromRGBO(20, 170, 60, 0.07),
      Color.fromRGBO(30, 150, 50, 0.06),
    ],
  );

  // I. Обсидиан 🪬
  static const obsidian = AppTheme(
    id: 'obsidian',
    name: 'Обсидиан',
    emoji: '🪬',
    gradientColors: [
      Color(0xFF08080C),
      Color(0xFF0C0C12),
      Color(0xFF090B10),
      Color(0xFF07070A),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(40, 60, 140, 0.22), radius: 400),
      OrbConfig(color: Color.fromRGBO(20, 40, 100, 0.16), radius: 310),
    ],
    accentColors: [
      Color.fromRGBO(40, 60, 140, 0.09),
      Color.fromRGBO(20, 40, 100, 0.08),
      Color.fromRGBO(50, 70, 150, 0.07),
      Color.fromRGBO(30, 50, 120, 0.06),
    ],
  );

  // J. Графит 🩶
  static const graphite = AppTheme(
    id: 'graphite',
    name: 'Графит',
    emoji: '🩶',
    gradientColors: [
      Color(0xFF111113),
      Color(0xFF161618),
      Color(0xFF191919),
      Color(0xFF111112),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(180, 185, 210, 0.10), radius: 375),
      OrbConfig(color: Color.fromRGBO(140, 145, 175, 0.07), radius: 280),
    ],
    accentColors: [
      Color.fromRGBO(180, 185, 210, 0.09),
      Color.fromRGBO(140, 145, 175, 0.08),
      Color.fromRGBO(160, 165, 190, 0.07),
      Color.fromRGBO(120, 125, 155, 0.06),
    ],
  );

  // K. Полночь 🌑
  static const midnight = AppTheme(
    id: 'midnight',
    name: 'Полночь',
    emoji: '🌑',
    gradientColors: [
      Color(0xFF040610),
      Color(0xFF080C1C),
      Color(0xFF0C1028),
      Color(0xFF040610),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(30, 50, 160, 0.25), radius: 360),
      OrbConfig(color: Color.fromRGBO(50, 70, 190, 0.10), radius: 200),
    ],
    accentColors: [
      Color.fromRGBO(30, 50, 160, 0.09),
      Color.fromRGBO(50, 70, 190, 0.08),
      Color.fromRGBO(40, 60, 175, 0.07),
      Color.fromRGBO(35, 55, 145, 0.06),
    ],
  );

  // L. Эспрессо ☕
  static const espresso = AppTheme(
    id: 'espresso',
    name: 'Эспрессо',
    emoji: '☕',
    gradientColors: [
      Color(0xFF0E0804),
      Color(0xFF160C05),
      Color(0xFF1C1008),
      Color(0xFF0D0703),
    ],
    orbs: [
      OrbConfig(color: Color.fromRGBO(160, 80, 10, 0.22), radius: 350),
      OrbConfig(color: Color.fromRGBO(200, 120, 20, 0.08), radius: 190),
    ],
    accentColors: [
      Color.fromRGBO(160, 80, 10, 0.09),
      Color.fromRGBO(200, 120, 20, 0.08),
      Color.fromRGBO(180, 100, 15, 0.07),
      Color.fromRGBO(140, 70, 10, 0.06),
    ],
  );
}

class OrbConfig {
  final Color color;
  final double radius;

  const OrbConfig({
    required this.color,
    required this.radius,
  });
}
