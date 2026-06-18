import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBrown = Color(0xFF6D4C41); // #6D4C41
  static const Color accentOrange = Color(0xFFE07A5F); // #E07A5F (Customer & Host Accent)
  static const Color accentPurple = Color(0xFF8E24AA); // #8E24AA (Author Accent)
  static const Color backgroundColor = Color(0xFFFDFAE7); // #FDFAE7 (Warm background)
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF424242);
  static const Color textLight = Color(0xFF757575);

  // Background Gradients
  static const List<Color> mainGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  static LinearGradient getMainGradient() {
    return const LinearGradient(
      colors: mainGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Theme Data Builder
  static ThemeData getTheme(Color accentColor) {
    return ThemeData(
      primaryColor: primaryBrown,
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrown,
        primary: primaryBrown,
        secondary: accentColor,
        background: backgroundColor,
      ),
      fontFamily: 'BeVietnamPro',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryBrown),
        titleTextStyle: TextStyle(
          color: primaryBrown,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: 'BeVietnamPro',
        ),
      ),
    );
  }

  // Shared Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: primaryBrown.withOpacity(0.7)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBrown, width: 1.5),
      ),
    );
  }

  // Shared Box Decoration for Cards
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double borderRadius = 24.0,
    double blurRadius = 15.0,
    Offset offset = const Offset(0, 8),
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: blurRadius,
          offset: offset,
        )
      ],
    );
  }
}
