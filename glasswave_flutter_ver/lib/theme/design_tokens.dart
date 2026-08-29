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

  /* ── Ring gradients ───────────────────────────────────────────────────
     IMPORTANT: React only paints a ring where it explicitly renders a
     `.glass-ring` element. `glassBase()` alone (search bar, chips, settings
     panels, dialogs…) has NO ring and NO sheen — only the fill, the 1px
     border and the box-shadow with its two inset edges. The ring colours
     below are the four places React does draw one. */

  /// `.glass-ring` — rgba(255,255,255,0.35) / 0.08 @40% / 0.02.
  static const List<Color> ringCard = [
    Color(0x59FFFFFF),
    Color(0x14FFFFFF),
    Color(0x05FFFFFF),
  ];

  /// `.card:hover .glass-ring` — 0.60 / 0.14 @45% / 0.02.
  static const List<Color> ringCardHover = [
    Color(0x99FFFFFF),
    Color(0x24FFFFFF),
    Color(0x05FFFFFF),
  ];

  /// `BottomNav` ring — rgba(255,255,255,0.28) → 0.04 @60%.
  static const List<Color> ringNav = [Color(0x47FFFFFF), Color(0x0AFFFFFF)];
  static const List<double> ringNavStops = [0.0, 0.6];

  /// `EditorModal` ring — rgba(255,255,255,0.40) / 0.06 @45% / 0.01.
  static const List<Color> ringModal = [
    Color(0x66FFFFFF),
    Color(0x0FFFFFFF),
    Color(0x03FFFFFF),
  ];
  static const List<double> ringModalStops = [0.0, 0.45, 1.0];

  /// `ReminderModal` ring — rgba(255,255,255,0.38) / 0.05 @50% / 0.
  static const List<Color> ringReminder = [
    Color(0x61FFFFFF),
    Color(0x0DFFFFFF),
    Color(0x00FFFFFF),
  ];
  static const List<double> ringReminderStops = [0.0, 0.5, 1.0];

  /* ── Inset edges ──────────────────────────────────────────────────────
     The `inset 0 1px 0 …` halves of every `glassBase()` shadow. */

  /// `inset 0 1px 0 rgba(255,255,255,0.15)`.
  static const Color innerTop = Color(0x26FFFFFF);

  /// `inset 0 -1px 0 rgba(0,0,0,0.20)`.
  static const Color innerBottom = Color(0x33000000);

  /// Active theme tile: `inset 0 1px 0 rgba(255,255,255,0.28)`.
  static const Color innerTopStrong = Color(0x47FFFFFF);

  /// `.glass-sheen` base opacity (1.0 on hover, 0.7 on the FAB).
  static const double sheenOpacity = 0.6;
}
