import 'package:flutter/material.dart';

/// SIKERA Design System Theme
/// Berdasarkan spesifikasi DESIGN.md dan aturan antislop (ENERGY 2 / RHYTHM 2 / MOTION 1):
/// - Identitas: Deep Navy (#03045E), Ocean Blue (#0077B6), Cyan (#00B4D8), Light Cyan (#90E0EF), Pale Cyan (#CAF0F8)
/// - Kontras WCAG AA terpenuhi di kedua mode (terang dan gelap)
/// - Komponen konsisten (radius 8, 12, 16, 20, 24; tap target min 44px)
class AppTheme {
  AppTheme._();

  // Core Brand Palette (DESIGN.md Section 3)
  static const Color primary900 = Color(0xFF03045E); // Deep Navy - Highest emphasis, nav, headings
  static const Color primary700 = Color(0xFF0077B6); // Ocean Blue - Primary action, buttons, links
  static const Color primary500 = Color(0xFF00B4D8); // Cyan - Accent, icons, highlights, progress
  static const Color primary200 = Color(0xFF90E0EF); // Light Cyan - Soft accent, selected surfaces
  static const Color primary50 = Color(0xFFCAF0F8);  // Pale Cyan - Very light background, cards, info

  // Backwards compatibility aliases
  static const Color primaryTeal = primary900;
  static const Color primary = primary700;
  static const Color primaryDark = primary900;
  static const Color primaryLight = primary50;
  static const Color accent = primary500;
  static const Color accentLight = primary200;

  // Semantic Colors (DESIGN.md Section 3)
  static const Color success = Color(0xFF16803C);
  static const Color successLight = Color(0xFFEAF7EE);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningLight = Color(0xFFFEF7EC);
  static const Color error = Color(0xFFC53030);
  static const Color errorLight = Color(0xFFFDF2F2);
  static const Color info = Color(0xFF0077B6);
  static const Color statusSuccess = success;
  static const Color statusWarning = warning;
  static const Color statusError = error;

  // Light Theme Tokens (DESIGN.md Section 4)
  static const Color backgroundLight = Color(0xFFF7FCFE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color softSurfaceLight = Color(0xFFCAF0F8);
  static const Color textPrimaryLight = Color(0xFF03045E);
  static const Color textSecondaryLight = Color(0xFF334E68);
  static const Color textMutedLight = Color(0xFF627D98);
  static const Color borderLight = Color(0xFFD6EAF0);
  static const Color strongBorderLight = Color(0xFF90E0EF);

  // Dark Theme Tokens (DESIGN.md Section 5)
  static const Color backgroundDark = Color(0xFF071A2B);
  static const Color surfaceDark = Color(0xFF0D2638);
  static const Color elevatedSurfaceDark = Color(0xFF12354A);
  static const Color softAccentSurfaceDark = Color(0xFF123E52);
  static const Color textPrimaryDark = Color(0xFFF1FBFD);
  static const Color textSecondaryDark = Color(0xFFB8D5DE);
  static const Color textMutedDark = Color(0xFF86AAB7);
  static const Color borderDark = Color(0xFF12354A);

  // Brand Gradient (DESIGN.md Section 23)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary900, primary700, primary500],
    stops: [0.0, 0.55, 1.0],
  );

  // Elevation & Crisp Shadows (DESIGN.md Section 10)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(3, 4, 94, 0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevatedCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(3, 4, 94, 0.08),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Official Radius Tokens (DESIGN.md Section 9)
  static const double radiusSm = 8.0;     // Small controls
  static const double radiusMd = 12.0;    // Inputs, compact cards, buttons
  static const double radiusLg = 16.0;    // Standard cards
  static const double radiusXl = 20.0;    // Feature cards, banners
  static const double radius2Xl = 24.0;   // Hero surfaces
  static const double radiusPill = 999.0; // Pills & status tags

  // Backwards-compatibility aliases for existing assertions
  static const double jagoCardRadius = radiusXl;
  static const double jagoPillRadius = 28.0;
  static const Color primary100 = Color(0xFFBBEBF6);
  static const Color pocketSurfaceLight = Color(0xFFF0F9FD);
  static const Color pocketSurfaceDark = Color(0xFF0F2B40);
  static const List<BoxShadow> jagoPocketShadow = cardShadow;
  static const List<BoxShadow> jagoSoftShadow = elevatedCardShadow;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary700,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary700,
        secondary: primary500,
        surface: surfaceLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryLight),
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderLight, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderLight, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderLight, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary700, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.0),
        ),
        labelStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
        hintStyle: const TextStyle(color: textMutedLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary700,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary700,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primary700, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primary50,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary700,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMutedLight,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary500,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primary500,
        secondary: primary700,
        surface: surfaceDark,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryDark),
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderDark, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderDark, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderDark, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.0),
        ),
        labelStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
        hintStyle: const TextStyle(color: textMutedDark, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary700,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary500,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primary500, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: softAccentSurfaceDark,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary500,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMutedDark,
          );
        }),
      ),
    );
  }
}
