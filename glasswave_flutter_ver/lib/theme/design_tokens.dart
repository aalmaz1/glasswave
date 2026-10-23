import 'package:flutter/material.dart';

abstract final class G {
  // Apple visionOS-level crystal glass tint
  static const Color bg = Color(0x1FFFFFFF); // ~12% pure white frosted glass surface
  static const Color bgHov = Color(0x33FFFFFF); // ~20% white on hover
  static const Color border = Color(0x3DFFFFFF); // ~24% crisp specular rim border
  static const Color borderHov = Color(0x75FFFFFF); // ~46% bright rim on hover
  static const Color textPrimary = Color(0xF5FFFFFF); // 96% crisp primary text
  static const Color textSecondary = Color(0xB8FFFFFF); // 72% secondary text
  static const Color textMuted = Color(0x66FFFFFF); // 40% subtle muted text
  static const Color overlay = Color(0x66000000); // 40% soft backdrop tint
  static const double radius = 22;

  // Ultra-realistic dual-layer glass elevation shadows (Apple visionOS style)
  static List<BoxShadow> glassShadow({bool hover = false}) {
    return [
      BoxShadow(
        color: Color(hover ? 0x3D000000 : 0x24000000), // Soft ambient contact shadow
        blurRadius: hover ? 36 : 24,
        spreadRadius: hover ? -2 : -4,
        offset: Offset(0, hover ? 14 : 8),
      ),
      BoxShadow(
        color: Color(hover ? 0x24000000 : 0x14000000), // Wide diffused backdrop shadow
        blurRadius: hover ? 72 : 48,
        spreadRadius: 0,
        offset: Offset(0, hover ? 24 : 14),
      ),
    ];
  }

  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: 60,
      spreadRadius: -6,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 100,
      offset: Offset(0, 36),
    ),
  ];

  static const List<BoxShadow> confirmShadow = [
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: 50,
      spreadRadius: -4,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x38000000),
      blurRadius: 90,
      offset: Offset(0, 32),
    ),
  ];

  static const List<double> ringStops = [0.0, 0.48, 1.0];

  static const List<double> ringStopsHover = [0.0, 0.52, 1.0];

  // Specular rim light gradient (brighter top-left, soft bottom-right)
  static const List<Color> ringCard = [
    Color(0x75FFFFFF), // 46% specular top highlight
    Color(0x28FFFFFF), // 16% mid-edge reflection
    Color(0x12FFFFFF), // 7% subtle base rim
  ];

  static const List<Color> ringCardHover = [
    Color(0xBFFFFFFF), // 75% bright hover edge
    Color(0x47FFFFFF),
    Color(0x1FFFFFFF),
  ];

  static const List<Color> ringNav = [Color(0x66FFFFFF), Color(0x14FFFFFF)];
  static const List<double> ringNavStops = [0.0, 0.7];

  static const List<Color> ringModal = [
    Color(0x8CFFFFFF),
    Color(0x24FFFFFF),
    Color(0x0AFFFFFF),
  ];
  static const List<double> ringModalStops = [0.0, 0.48, 1.0];

  static const List<Color> ringReminder = [
    Color(0x80FFFFFF),
    Color(0x24FFFFFF),
    Color(0x05FFFFFF),
  ];
  static const List<double> ringReminderStops = [0.0, 0.5, 1.0];

  // Top specular light catch
  static const Color innerTop = Color(0x47FFFFFF); // ~28% clean white top edge catch

  // Bottom specular light refraction (NO MORE DARK BLACK LINE!)
  static const Color innerBottom = Color(0x1FFFFFFF); // ~12% white light refraction

  static const Color innerTopStrong = Color(0x70FFFFFF);

  static const double sheenOpacity = 0.75;
}
