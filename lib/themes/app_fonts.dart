import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w300,
          fontSize: 57,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w300,
          fontSize: 45,
        ),
        displaySmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          fontSize: 36,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      );
}
