import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color darkCard = Color(0xFF121212);
  
  // Dark Mode Colors (Pitch Black)
  static const Color darkBg = Colors.black;
  static const Color darkSurface = Color(0xFF121212);

  // Accent Colors (High Contrast)
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color accentBlue = Color(0xFF007AFF);
  
  static const Color pastelPurple = Color(0xFFE5E0FF);
  static const Color pastelGreen = Color(0xFFE0F5E9);
  static const Color pastelPeach = Color(0xFFFFE5D9);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: darkCard,
      colorScheme: const ColorScheme.light(
        primary: darkCard,
        secondary: accentBlue,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: neonCyan,
        onSecondary: Colors.black,
        surface: darkSurface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
