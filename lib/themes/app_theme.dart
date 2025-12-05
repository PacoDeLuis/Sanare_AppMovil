import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================
  static const Color primaryBlue = Color(0xFF7FA8D8); // azul claro
  static const Color darkBlue = Color(0xFF4C6FAF); // azul profundo
  static const Color softPink = Color(0xFFE8D1D1); // rosa suave
  static const Color softGray = Color(0xFFEEF1F6); // gris muy claro
  static const Color textDark = Color(0xFF2C3E50); // texto profesional

  // ============================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Fuente global (Google Fonts)
    textTheme: GoogleFonts.poppinsTextTheme(),

    // Color scheme (seeded)
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      secondary: darkBlue,
      background: softGray,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),

    // Scaffold background
    scaffoldBackgroundColor: softGray,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Elevated buttons (global)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(), // pill shape
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),

    // Card theme (compatible con Material 3)
      cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),


    // Input (TextField) global
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
    ),

    // Card color shortcut (asegura coherencia)
    cardColor: Colors.white,

    // Text theme tweaks
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryBlue,
    ),
  );
}