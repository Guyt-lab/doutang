import 'package:flutter/material.dart';

class DoutangTheme {
  DoutangTheme._();

  // Palette
  static const Color primary = Color(0xFF2D6A4F);      // vert foncé — nid, nature
  static const Color primaryLight = Color(0xFF52B788);  // vert clair
  static const Color primarySurface = Color(0xFFD8F3DC); // surface verte
  static const Color accent = Color(0xFFE9C46A);        // ambre — chaleur
  static const Color danger = Color(0xFFE63946);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color border = Color(0xFFE9ECEF);

  // Score colors
  static const Color scoreExcellent = Color(0xFF52B788);
  static const Color scoreGood = Color(0xFF90BE6D);
  static const Color scoreMid = Color(0xFFE9C46A);
  static const Color scoreLow = Color(0xFFF4A261);
  static const Color scorePoor = Color(0xFFE63946);

  static Color scoreColor(double score) {
    if (score >= 4.5) return scoreExcellent;
    if (score >= 3.5) return scoreGood;
    if (score >= 2.5) return scoreMid;
    if (score >= 1.5) return scoreLow;
    return scorePoor;
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: accent,
          surface: surface,
          error: danger,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: cardBg,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBg,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardTheme(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: border, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surface,
          selectedColor: primarySurface,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
          headlineMedium: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
          headlineSmall: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 15, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, color: textHint),
          labelLarge: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        ),
      );
}

// Espacements constants
class DSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// Rayons de bordure
class DRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius button = BorderRadius.all(Radius.circular(10));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(20));
}
