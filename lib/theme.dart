import 'package:flutter/material.dart';

class AppColors {
  static const Color orange     = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color orangeLight= Color(0xFFFFF7ED);
  static const Color navy       = Color(0xFF1E3A5F);
  static const Color navyLight  = Color(0xFF2D5282);
  static const Color green      = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFF0FDF4);
  static const Color red        = Color(0xFFDC2626);
  static const Color redLight   = Color(0xFFFEE2E2);
  static const Color blue       = Color(0xFF2563EB);
  static const Color blueLight  = Color(0xFFEFF6FF);
  static const Color purple     = Color(0xFF7C3AED);
  static const Color purpleLight= Color(0xFFF5F3FF);
  static const Color gold       = Color(0xFFD97706);
  static const Color goldLight  = Color(0xFFFFFBEB);
  static const Color teal       = Color(0xFF0D9488);
  static const Color tealLight  = Color(0xFFF0FDFA);
  static const Color rose       = Color(0xFFE11D48);
  static const Color roseLight  = Color(0xFFFFF1F2);
  static const Color bg         = Color(0xFFF9F6F1);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color grey       = Color(0xFF9CA3AF);
  static const Color greyDark   = Color(0xFF6B7280);
  static const Color dark       = Color(0xFF111827);
  static const Color border     = Color(0xFFE8E0D5);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      background: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.dark,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: AppColors.dark,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w900, color: AppColors.dark),
      bodyLarge:    TextStyle(fontWeight: FontWeight.w600, color: AppColors.dark),
      bodyMedium:   TextStyle(fontWeight: FontWeight.w500, color: AppColors.dark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'Nunito'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.grey, fontFamily: 'Nunito'),
    ),
  );
}
