import 'package:flutter/material.dart';

enum ThemeId {
  warmSunset, arctic, neon, nordic, forest, silk, flare, abyss, ruby, slate, matcha, sahara
}

class OrbData {
  final Color color;
  final double size;
  final double top;
  final double left;

  OrbData({required this.color, required this.size, required this.top, required this.left});
}

class AppThemeData {
  final ThemeId id;
  final String name;
  final String emoji;
  final LinearGradient bg;
  final List<OrbData> orbs;
  final List<Color> accents;

  AppThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bg,
    required this.orbs,
    required this.accents,
  });
}

final List<AppThemeData> allThemes = [
  AppThemeData(
    id: ThemeId.warmSunset,
    name: "Warm Sunset",
    emoji: "🌅",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF8C42), Color(0xFFFF6B6B), Color(0xFF9B59B6)],
    ),
    orbs: [
      OrbData(color: const Color(0x50FF8C42), size: 700, top: -0.2, left: -0.1),
      OrbData(color: const Color(0x40FF6B6B), size: 500, top: 0.5, left: 0.6),
      OrbData(color: const Color(0x309B59B6), size: 450, top: 0.7, left: 0.2),
    ],
    accents: [
      const Color(0xFFFF8C42), const Color(0xFFFF6B6B), const Color(0xFF9B59B6),
    ],
  ),
  AppThemeData(
    id: ThemeId.arctic,
    name: "Arctic Frost",
    emoji: "❄️",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0F4F8), Color(0xFFD9E2EC), Color(0xFFBCCCDC)],
    ),
    orbs: [
      OrbData(color: const Color(0x40B0D0FF), size: 600, top: -0.1, left: -0.1),
      OrbData(color: const Color(0x30FFFFFF), size: 500, top: 0.4, left: 0.7),
    ],
    accents: [
      const Color(0xFF102A43), const Color(0xFF243B53), const Color(0xFF486581),
    ],
  ),
  AppThemeData(
    id: ThemeId.neon,
    name: "Neon Tokyo",
    emoji: "🌆",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D0221), Color(0xFF0F084B), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x50FF00FF), size: 600, top: -0.1, left: -0.1),
      OrbData(color: const Color(0x4000FFFF), size: 550, top: 0.4, left: 0.6),
    ],
    accents: [
      const Color(0xFFFF00FF), const Color(0xFF00FFFF), const Color(0xFFBD00FF),
    ],
  ),
  AppThemeData(
    id: ThemeId.nordic,
    name: "Nordic Night",
    emoji: "🏔️",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B262C), Color(0xFF0F4C75), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x303282B8), size: 650, top: -0.15, left: -0.05),
      OrbData(color: const Color(0x20BBE1FA), size: 400, top: 0.6, left: 0.5),
    ],
    accents: [
      const Color(0xFF3282B8), const Color(0xFFBBE1FA), const Color(0xFF0F4C75),
    ],
  ),
  AppThemeData(
    id: ThemeId.forest,
    name: "Emerald Forest",
    emoji: "🌲",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF040D12), Color(0xFF183D3D), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x305C8374), size: 620, top: -0.1, left: -0.05),
      OrbData(color: const Color(0x2093B1A6), size: 450, top: 0.5, left: 0.6),
    ],
    accents: [
      const Color(0xFF5C8374), const Color(0xFF93B1A6), const Color(0xFF040D12),
    ],
  ),
  AppThemeData(
    id: ThemeId.silk,
    name: "Lavender Silk",
    emoji: "🪻",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2D033B), Color(0xFF810CA8), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x40C147E9), size: 600, top: -0.12, left: -0.08),
      OrbData(color: const Color(0x30E5B8F4), size: 400, top: 0.6, left: 0.6),
    ],
    accents: [
      const Color(0xFFC147E9), const Color(0xFFE5B8F4), const Color(0xFF810CA8),
    ],
  ),
  AppThemeData(
    id: ThemeId.flare,
    name: "Solar Flare",
    emoji: "☀️",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF240B36), Color(0xFFC31432), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x40FF4B2B), size: 620, top: -0.15, left: -0.1),
      OrbData(color: const Color(0x30FF416C), size: 500, top: 0.4, left: 0.65),
    ],
    accents: [
      const Color(0xFFFF4B2B), const Color(0xFFFF416C), const Color(0xFFC31432),
    ],
  ),
  AppThemeData(
    id: ThemeId.abyss,
    name: "Ocean Abyss",
    emoji: "🌊",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    ),
    orbs: [
      OrbData(color: const Color(0x4000C9FF), size: 640, top: -0.15, left: -0.05),
      OrbData(color: const Color(0x3092FE9D), size: 450, top: 0.6, left: 0.6),
    ],
    accents: [
      const Color(0xFF00C9FF), const Color(0xFF92FE9D), const Color(0xFF203A43),
    ],
  ),
  AppThemeData(
    id: ThemeId.ruby,
    name: "Ruby Wine",
    emoji: "🍷",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0000), Color(0xFF4A0000), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x40FF0000), size: 600, top: -0.1, left: -0.08),
      OrbData(color: const Color(0x308B0000), size: 480, top: 0.5, left: 0.6),
    ],
    accents: [
      const Color(0xFFFF0000), const Color(0xFF8B0000), const Color(0xFF4A0000),
    ],
  ),
  AppThemeData(
    id: ThemeId.slate,
    name: "Slate Grey",
    emoji: "🩶",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232526), Color(0xFF414345), Color(0xFF000000)],
    ),
    orbs: [
      OrbData(color: const Color(0x20FFFFFF), size: 700, top: -0.2, left: -0.1),
      OrbData(color: const Color(0x10BDC3C7), size: 500, top: 0.45, left: 0.55),
    ],
    accents: [
      const Color(0xFFBDC3C7), const Color(0xFF2C3E50), const Color(0xFF414345),
    ],
  ),
  AppThemeData(
    id: ThemeId.matcha,
    name: "Matcha Tea",
    emoji: "🍵",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF134E4A), Color(0xFF0F766E), Color(0xFF115E59)],
    ),
    orbs: [
      OrbData(color: const Color(0x302DD4BF), size: 600, top: -0.1, left: -0.05),
      OrbData(color: const Color(0x20CCFBF1), size: 400, top: 0.6, left: 0.6),
    ],
    accents: [
      const Color(0xFF2DD4BF), const Color(0xFFCCFBF1), const Color(0xFF0F766E),
    ],
  ),
  AppThemeData(
    id: ThemeId.sahara,
    name: "Sahara Gold",
    emoji: "🏜️",
    bg: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF422006), Color(0xFF713F12), Color(0xFF451A03)],
    ),
    orbs: [
      OrbData(color: const Color(0x40FACC15), size: 620, top: -0.12, left: -0.08),
      OrbData(color: const Color(0x30FEF08A), size: 450, top: 0.5, left: 0.62),
    ],
    accents: [
      const Color(0xFFFACC15), const Color(0xFFFEF08A), const Color(0xFF713F12),
    ],
  ),
];
