import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the React Native (web) reference app.
/// Source: `src/app/theme.ts` → `G` object and `glassBase()`.
abstract final class G {
  static const Color bg = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color bgHov = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color border = Color(0x33FFFFFF); // rgba(255,255,255,0.20)
  static const Color borderHov = Color(0x66FFFFFF); // rgba(255,255,255,0.40)
  static const Color textPrimary = Color(0xEBFFFFFF); // rgba(255,255,255,0.92)
  static const Color textSecondary = Color(0x99FFFFFF); // rgba(255,255,255,0.60)
  static const Color textMuted = Color(0x4CFFFFFF); // rgba(255,255,255,0.30)
  static const Color overlay = Color(0x80000000); // rgba(0,0,0,0.50)
  static const double radius = 20;

  /// Outer box-shadow part of `glassBase()`.
  /// (Inset highlights are drawn as 1px layers inside [GlassContainer].)
  static List<BoxShadow> glassShadow({bool hover = false}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: hover ? 0.60 : 0.50),
        blurRadius: hover ? 60 : 40,
        offset: Offset(0, hover ? 20 : 10),
      ),
    ];
  }

  /// Editor / modal shadow: `0 32px 80px rgba(0,0,0,0.65)`.
  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0xA6000000),
      blurRadius: 80,
      offset: Offset(0, 32),
    ),
  ];

  /// Confirm dialog shadow: `0 28px 80px rgba(0,0,0,0.70)`.
  static const List<BoxShadow> confirmShadow = [
    BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 80,
      offset: Offset(0, 28),
    ),
  ];

  /// Ring gradient stops, same as `.glass-ring` (`0% / 40% / 100%`).
  static const List<double> ringStops = [0.0, 0.4, 1.0];

  /// `.card:hover .glass-ring` moves the middle stop to 45%.
  static const List<double> ringStopsHover = [0.0, 0.45, 1.0];
}
