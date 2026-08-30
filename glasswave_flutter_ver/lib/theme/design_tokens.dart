import 'package:flutter/material.dart';

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

  static List<BoxShadow> glassShadow({bool hover = false}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: hover ? 0.60 : 0.50),
        blurRadius: hover ? 60 : 40,
        offset: Offset(0, hover ? 20 : 10),
      ),
    ];
  }

  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0xA6000000),
      blurRadius: 80,
      offset: Offset(0, 32),
    ),
  ];

  static const List<BoxShadow> confirmShadow = [
    BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 80,
      offset: Offset(0, 28),
    ),
  ];

  static const List<double> ringStops = [0.0, 0.4, 1.0];

  static const List<double> ringStopsHover = [0.0, 0.45, 1.0];

  static const List<Color> ringCard = [
    Color(0x59FFFFFF),
    Color(0x14FFFFFF),
    Color(0x05FFFFFF),
  ];

  static const List<Color> ringCardHover = [
    Color(0x99FFFFFF),
    Color(0x24FFFFFF),
    Color(0x05FFFFFF),
  ];

  static const List<Color> ringNav = [Color(0x47FFFFFF), Color(0x0AFFFFFF)];
  static const List<double> ringNavStops = [0.0, 0.6];

  static const List<Color> ringModal = [
    Color(0x66FFFFFF),
    Color(0x0FFFFFFF),
    Color(0x03FFFFFF),
  ];
  static const List<double> ringModalStops = [0.0, 0.45, 1.0];

  static const List<Color> ringReminder = [
    Color(0x61FFFFFF),
    Color(0x0DFFFFFF),
    Color(0x00FFFFFF),
  ];
  static const List<double> ringReminderStops = [0.0, 0.5, 1.0];

  static const Color innerTop = Color(0x26FFFFFF);

  static const Color innerBottom = Color(0x33000000);

  static const Color innerTopStrong = Color(0x47FFFFFF);

  static const double sheenOpacity = 0.6;
}
