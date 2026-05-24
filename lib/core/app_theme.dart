import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:piawai/core/constants.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: kPrimary,
      scaffoldBackgroundColor: kBgOuter,
      appBarTheme: AppBarTheme(
        backgroundColor: kBgContent,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: kPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: kPrimary),
      ),
      cardTheme: CardThemeData(
        color: kBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kBgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kWhite,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodySmall: GoogleFonts.poppins(color: kTextSecondary),
        bodyMedium: GoogleFonts.poppins(color: kTextPrimary),
        bodyLarge: GoogleFonts.poppins(color: kTextPrimary),
        titleSmall: GoogleFonts.poppins(
          color: kTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: kTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.poppins(
          color: kTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: kDarkPrimary,
      scaffoldBackgroundColor: kDarkBgOuter,
      appBarTheme: AppBarTheme(
        backgroundColor: kDarkBgContent,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: kDarkPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: kDarkPrimary),
      ),
      cardTheme: CardThemeData(
        color: kDarkBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kDarkBgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDarkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDarkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDarkPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkPrimary,
          foregroundColor: kDarkBgOuter,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        bodySmall: GoogleFonts.poppins(color: kDarkTextSecondary),
        bodyMedium: GoogleFonts.poppins(color: kDarkTextPrimary),
        bodyLarge: GoogleFonts.poppins(color: kDarkTextPrimary),
        titleSmall: GoogleFonts.poppins(
          color: kDarkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: kDarkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.poppins(
          color: kDarkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
