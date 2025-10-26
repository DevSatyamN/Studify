import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Beautiful Blue Theme Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF29B6F6);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color studyDayColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFF9800);

  // Light Theme Colors
  static const Color lightSurfaceColor = Color(0xFFF5F7FA);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  // Pure AMOLED Dark Theme Colors
  static const Color darkSurfaceColor = Color(0xFF000000);
  static const Color darkCardColor = Color(0xFF0A0A0A);
  static const Color darkSecondaryColor = Color(0xFF1A1A1A);
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color glassBorderColor = Color(0x33FFFFFF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: lightSurfaceColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ),
    scaffoldBackgroundColor: lightSurfaceColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: lightCardColor,
      foregroundColor: Colors.black87,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      color: lightCardColor,
      shadowColor: primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: darkSurfaceColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surfaceContainer: darkCardColor,
      surfaceContainerHighest: darkSecondaryColor,
    ),
    scaffoldBackgroundColor: darkSurfaceColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: darkCardColor,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  // Glassmorphism AppBar decoration
  static BoxDecoration glassAppBarDecoration = BoxDecoration(
    color: glassColor,
    border: Border.all(
      color: glassBorderColor,
      width: 0.5,
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  );

  // Glassmorphism card decoration
  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: glassColor,
    border: Border.all(
      color: glassBorderColor,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(16),
  );
}
