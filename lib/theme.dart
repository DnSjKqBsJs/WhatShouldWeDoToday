import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFFF7F4EF);
  static const Color bgCard = Color(0xFFF2EEE7);
  static const Color surfaceSolid = Color(0xFFFBF9F5);
  static const Color accent = Color(0xFF2A8FA0);
  static const Color accentLight = Color(0xFFD4EDF1);
  static const Color accentMid = Color(0xFF6BBFCC);
  static const Color textPrimary = Color(0xFF1A1714);
  static const Color textMid = Color(0xFF6B6560);
  static const Color textLight = Color(0xFFA09890);
  static const Color border = Color(0x4DC8BEAA);
  static const Color borderLight = Color(0xBFFFFFFA);
  static const Color navBg = Color(0xE6140F0A);

  // Shadows
  static List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x1A3C3220), blurRadius: 24, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x213C3220), blurRadius: 32, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x2E3C3220), blurRadius: 48, offset: Offset(0, 16)),
  ];

  // Border radius
  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusPill = 50;

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
    fontFamily: 'DMSans',
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.3,
    fontFamily: 'DMSans',
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    fontFamily: 'DMSans',
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'DMSans',
  );
  static const TextStyle bodyMid = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textMid,
    fontFamily: 'DMSans',
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textLight,
    fontFamily: 'DMSans',
  );

  // MaterialApp theme
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.dmSansTextTheme(),
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.light(primary: accent, surface: surfaceSolid),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
