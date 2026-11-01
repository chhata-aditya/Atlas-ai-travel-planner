import 'package:flutter/material.dart';

class AppColors {
  // Brand Teals (Exact match to designs)
  static const Color primaryTeal = Color(0xFF006D77);
  static const Color primary = Color(0xFF006D77);
  static const Color darkTeal = Color(0xFF08495A);
  static const Color primaryDark = Color(0xFF08495A);
  static const Color deepNavy = Color(0xFF0F2C3A);
  static const Color lightTeal = Color(0xFF83C5BE);
  static const Color primaryLight = Color(0xFF83C5BE);
  static const Color accent = Color(0xFF00798C);
  static const Color softTealBg = Color(0xFFE2F6F8);

  // Accents & Alerts
  static const Color alertCoral = Color(0xFFFF6B6B);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color alertOrange = Color(0xFFFF7A59);
  static const Color alertLightBg = Color(0xFFFFECE8);
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color warningLightBg = Color(0xFFFEF3C7);
  static const Color successMint = Color(0xFF10B981);
  static const Color accentMint = Color(0xFF10B981);
  static const Color successLightBg = Color(0xFFD1FAE5);

  // Category Icon Backgrounds
  static const Color flightCircleBg = Color(0xFFE2F6F8);
  static const Color hotelCircleBg = Color(0xFFFFEFE7);
  static const Color tourCircleBg = Color(0xFFFBE8E8);
  static const Color activityCircleBg = Color(0xFFF0EAFA);

  // Category Icon Foreground Colors
  static const Color flightIcon = Color(0xFF00798C);
  static const Color hotelIcon = Color(0xFFD97706);
  static const Color tourIcon = Color(0xFFDC2626);
  static const Color activityIcon = Color(0xFF7C3AED);

  // Backgrounds & Surface
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1A2D35);
  static const Color textSecondary = Color(0xFF6B7C85);
  static const Color textMuted = Color(0xFF9EACB4);
  static const Color textWhite = Colors.white;

  // Border & Dividers
  static const Color border = Color(0xFFE5EBEF);
  static const Color divider = Color(0xFFEDF2F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006D77), Color(0xFF08495A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF08495A), Color(0xFF006D77), Color(0xFF83C5BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        primary: AppColors.primaryTeal,
        secondary: AppColors.lightTeal,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTeal),
        titleTextStyle: TextStyle(
          color: AppColors.darkTeal,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
