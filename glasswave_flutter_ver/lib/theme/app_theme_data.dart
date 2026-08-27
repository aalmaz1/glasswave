import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ThemeId {
  sunset, ice, mono, cyber, aurora, rose, cosmos, forest,
  obsidian, graphite, midnight, espresso,
}

class OrbData {
  final Color color;
  final double size;
  final double top;
  final double left;

  const OrbData({required this.color, required this.size, required this.top, required this.left});
}

class AppThemeData {
  final ThemeId id;
  final String emoji;

  /// CSS gradient angle in degrees, exactly as written in the React app
  /// (`linear-gradient(145deg, …)`): 0 = to top, 90 = to right.
  final double bgAngle;
  final List<Color> bgColors;
  final List<double> bgStops;
  final List<OrbData> orbs;
  final List<Color> accents;

  const AppThemeData({
    required this.id,
    required this.emoji,
    required this.bgAngle,
    required this.bgColors,
    required this.bgStops,
    required this.orbs,
    required this.accents,
  });

  /// Builds the background gradient for a box of [size] so that it matches a
  /// CSS `linear-gradient(<angle>deg, …)` pixel for pixel.
  ///
  /// CSS positions the gradient line through the centre of the box along
  /// `(sin a, -cos a)` and stretches it until it covers every corner
  /// (`L = |W·sin a| + |H·cos a|`). Flutter alignments are relative to half the
  /// box, hence the `L / W` and `L / H` scaling below.
  LinearGradient bgGradient(Size size) {
    final rad = bgAngle * math.pi / 180.0;
    final dx = math.sin(rad);
    final dy = -math.cos(rad);
    final w = size.width <= 0 ? 1.0 : size.width;
    final h = size.height <= 0 ? 1.0 : size.height;
    final length = (w * dx).abs() + (h * dy).abs();
    final ex = dx * length / w;
    final ey = dy * length / h;
    return LinearGradient(
      begin: Alignment(-ex, -ey),
      end: Alignment(ex, ey),
      colors: bgColors,
      stops: bgStops,
    );
  }
}

final List<AppThemeData> allThemes = [
  AppThemeData(
    id: ThemeId.sunset,
    emoji: '🌅',
    bgAngle: 145,
    bgColors: const [Color(0xFF130500), Color(0xFF2E0C00), Color(0xFF4A1400), Color(0xFF6B1E00), Color(0xFF8A2800)],
    bgStops: const [0.0, 0.28, 0.52, 0.75, 1.0],
    orbs: [
      OrbData(color: const Color(0x38FF6E14), size: 680, top: -0.18, left: -0.10),
      OrbData(color: const Color(0x28C83200), size: 520, top: 0.38, left: 0.58),
      OrbData(color: const Color(0x19FFA01E), size: 400, top: 0.72, left: 0.05),
      OrbData(color: const Color(0x17B42800), size: 280, top: 0.12, left: 0.72),
    ],
    accents: [
      const Color(0x17FF9632), const Color(0x14FF5A1E), const Color(0x12F0BE3C), const Color(0x14D2460A),
    ],
  ),
  AppThemeData(
    id: ThemeId.ice,
    emoji: '🧊',
    bgAngle: 145,
    bgColors: const [Color(0xFF00080F), Color(0xFF001525), Color(0xFF002440), Color(0xFF003658), Color(0xFF004870)],
    bgStops: const [0.0, 0.30, 0.58, 0.80, 1.0],
    orbs: [
      OrbData(color: const Color(0x2E00B4E6), size: 620, top: -0.12, left: -0.08),
      OrbData(color: const Color(0x230078BE), size: 500, top: 0.40, left: 0.62),
      OrbData(color: const Color(0x173CD2DC), size: 380, top: 0.68, left: 0.04),
      OrbData(color: const Color(0x1464B4FF), size: 260, top: 0.15, left: 0.70),
    ],
    accents: [
      const Color(0x1428C8FF), const Color(0x1400B4C8), const Color(0x1250AAFF), const Color(0x140096D2),
    ],
  ),
  AppThemeData(
    id: ThemeId.mono,
    emoji: '🪨',
    bgAngle: 150,
    bgColors: const [Color(0xFF0E0E10), Color(0xFF141416), Color(0xFF1A1A1C), Color(0xFF111113)],
    bgStops: const [0.0, 0.35, 0.65, 1.0],
    orbs: [
      OrbData(color: const Color(0x12C8C8DC), size: 700, top: -0.15, left: -0.08),
      OrbData(color: const Color(0x0DA0A0BE), size: 520, top: 0.42, left: 0.60),
      OrbData(color: const Color(0x0A646EB4), size: 360, top: 0.70, left: 0.05),
    ],
    accents: [
      const Color(0x12DCDCEF), const Color(0x0F96A0FF), const Color(0x0DFF96C8), const Color(0x0FBEBED2),
    ],
  ),
  AppThemeData(
    id: ThemeId.cyber,
    emoji: '🌺',
    bgAngle: 140,
    bgColors: const [Color(0xFF001212), Color(0xFF002828), Color(0xFF004040), Color(0xFF003535), Color(0xFF380A20)],
    bgStops: const [0.0, 0.30, 0.55, 0.70, 1.0],
    orbs: [
      OrbData(color: const Color(0x3300DCC8), size: 600, top: -0.12, left: -0.07),
      OrbData(color: const Color(0x2EC81E5A), size: 540, top: 0.38, left: 0.58),
      OrbData(color: const Color(0x1900B4AA), size: 380, top: 0.72, left: 0.05),
      OrbData(color: const Color(0x17A01450), size: 280, top: 0.10, left: 0.70),
    ],
    accents: [
      const Color(0x1400E6D2), const Color(0x14D2286E), const Color(0x1200C8BE), const Color(0x12B41E64),
    ],
  ),
  AppThemeData(
    id: ThemeId.aurora,
    emoji: '🌌',
    bgAngle: 155,
    bgColors: const [Color(0xFF010806), Color(0xFF031A0E), Color(0xFF051828), Color(0xFF090B22), Color(0xFF06041A)],
    bgStops: const [0.0, 0.28, 0.55, 0.80, 1.0],
    orbs: [
      OrbData(color: const Color(0x2E00F078), size: 660, top: -0.16, left: -0.09),
      OrbData(color: const Color(0x333C1EE6), size: 560, top: 0.36, left: 0.56),
      OrbData(color: const Color(0x1C00BEAA), size: 400, top: 0.70, left: 0.03),
      OrbData(color: const Color(0x177800FF), size: 320, top: 0.08, left: 0.68),
      OrbData(color: const Color(0x1200FFA0), size: 240, top: 0.55, left: 0.20),
    ],
    accents: [
      const Color(0x1200FF82), const Color(0x125032FF), const Color(0x1200D2B4), const Color(0x0F64FFBE),
    ],
  ),
  AppThemeData(
    id: ThemeId.rose,
    emoji: '🥀',
    bgAngle: 145,
    bgColors: const [Color(0xFF0A0005), Color(0xFF180008), Color(0xFF260010), Color(0xFF180018), Color(0xFF0E000C)],
    bgStops: const [0.0, 0.32, 0.60, 0.82, 1.0],
    orbs: [
      OrbData(color: const Color(0x38E60050), size: 620, top: -0.14, left: -0.08),
      OrbData(color: const Color(0x2B9600C8), size: 520, top: 0.38, left: 0.60),
      OrbData(color: const Color(0x19FF3C78), size: 380, top: 0.68, left: 0.04),
      OrbData(color: const Color(0x147800B4), size: 300, top: 0.15, left: 0.70),
    ],
    accents: [
      const Color(0x14FF326E), const Color(0x14D20096), const Color(0x12BE00FF), const Color(0x12FF64AA),
    ],
  ),
  AppThemeData(
    id: ThemeId.cosmos,
    emoji: '🔭',
    bgAngle: 148,
    bgColors: const [Color(0xFF020008), Color(0xFF08001E), Color(0xFF110030), Color(0xFF08001A), Color(0xFF030010)],
    bgStops: const [0.0, 0.32, 0.60, 0.82, 1.0],
    orbs: [
      OrbData(color: const Color(0x336E00FF), size: 640, top: -0.15, left: -0.08),
      OrbData(color: const Color(0x293C00D2), size: 520, top: 0.40, left: 0.58),
      OrbData(color: const Color(0x17B43CFF), size: 380, top: 0.72, left: 0.06),
      OrbData(color: const Color(0x0FFF78FF), size: 280, top: 0.18, left: 0.72),
      OrbData(color: const Color(0x0F5000C8), size: 220, top: 0.50, left: 0.28),
    ],
    accents: [
      const Color(0x148232FF), const Color(0x12BE46FF), const Color(0x0FFF82FF), const Color(0x145A00D2),
    ],
  ),
  AppThemeData(
    id: ThemeId.forest,
    emoji: '🌲',
    bgAngle: 145,
    bgColors: const [Color(0xFF010602), Color(0xFF030E05), Color(0xFF061808), Color(0xFF081E0A), Color(0xFF040C06)],
    bgStops: const [0.0, 0.30, 0.58, 0.80, 1.0],
    orbs: [
      OrbData(color: const Color(0x2B00BE37), size: 620, top: -0.13, left: -0.07),
      OrbData(color: const Color(0x21008223), size: 500, top: 0.40, left: 0.62),
      OrbData(color: const Color(0x1428D246), size: 380, top: 0.70, left: 0.05),
      OrbData(color: const Color(0x0FA0FF50), size: 260, top: 0.14, left: 0.68),
    ],
    accents: [
      const Color(0x1200D24B), const Color(0x1232BE3C), const Color(0x0F82FF46), const Color(0x12009637),
    ],
  ),
  AppThemeData(
    id: ThemeId.obsidian,
    emoji: '🪬',
    bgAngle: 158,
    bgColors: const [Color(0xFF08080C), Color(0xFF0C0C12), Color(0xFF090B10), Color(0xFF07070A)],
    bgStops: const [0.0, 0.35, 0.65, 1.0],
    orbs: [
      OrbData(color: const Color(0x38283C8C), size: 800, top: -0.25, left: -0.15),
      OrbData(color: const Color(0x29142864), size: 620, top: 0.45, left: 0.50),
      OrbData(color: const Color(0x193C50A0), size: 420, top: 0.75, left: -0.05),
      OrbData(color: const Color(0x1F001E50), size: 300, top: 0.05, left: 0.65),
    ],
    accents: [
      const Color(0x0F3C50C8), const Color(0x0F283CB4), const Color(0x0D5064DC), const Color(0x0F1E32A0),
    ],
  ),
  AppThemeData(
    id: ThemeId.graphite,
    emoji: '🩶',
    bgAngle: 152,
    bgColors: const [Color(0xFF111113), Color(0xFF161618), Color(0xFF191919), Color(0xFF111112)],
    bgStops: const [0.0, 0.38, 0.62, 1.0],
    orbs: [
      OrbData(color: const Color(0x19B4B9D2), size: 750, top: -0.20, left: -0.12),
      OrbData(color: const Color(0x128C91AF), size: 560, top: 0.42, left: 0.52),
      OrbData(color: const Color(0x0D646996), size: 380, top: 0.70, left: -0.04),
      OrbData(color: const Color(0x0AC8C3DC), size: 280, top: 0.10, left: 0.68),
    ],
    accents: [
      const Color(0x0FD2D7EB), const Color(0x0FA0A5C8), const Color(0x0D8287B9), const Color(0x0DB9BED7),
    ],
  ),
  AppThemeData(
    id: ThemeId.midnight,
    emoji: '🌑',
    bgAngle: 148,
    bgColors: const [Color(0xFF040610), Color(0xFF080C1C), Color(0xFF0C1028), Color(0xFF070A1A), Color(0xFF040610)],
    bgStops: const [0.0, 0.32, 0.60, 0.82, 1.0],
    orbs: [
      OrbData(color: const Color(0x401E32A0), size: 720, top: -0.20, left: -0.12),
      OrbData(color: const Color(0x2E142378), size: 560, top: 0.42, left: 0.54),
      OrbData(color: const Color(0x193246BE), size: 400, top: 0.72, left: 0.04),
      OrbData(color: const Color(0x1F0F1964), size: 300, top: 0.08, left: 0.66),
    ],
    accents: [
      const Color(0x12506EFF), const Color(0x123C5AE6), const Color(0x0F3250D2), const Color(0x0F6482FF),
    ],
  ),
  AppThemeData(
    id: ThemeId.espresso,
    emoji: '☕',
    bgAngle: 150,
    bgColors: const [Color(0xFF0E0804), Color(0xFF160C05), Color(0xFF1C1008), Color(0xFF140B06), Color(0xFF0D0703)],
    bgStops: const [0.0, 0.32, 0.60, 0.82, 1.0],
    orbs: [
      OrbData(color: const Color(0x38A0500A), size: 700, top: -0.18, left: -0.10),
      OrbData(color: const Color(0x29783705), size: 540, top: 0.42, left: 0.54),
      OrbData(color: const Color(0x14C87814), size: 380, top: 0.70, left: 0.04),
      OrbData(color: const Color(0x19642D00), size: 280, top: 0.10, left: 0.68),
    ],
    accents: [
      const Color(0x12D2963C), const Color(0x12BE7323), const Color(0x0FE6AA50), const Color(0x0FAA5F19),
    ],
  ),
];
