import 'package:flutter/material.dart';

class AppTheme {
  static const Color _bg = Color(0xFF07111A);
  static const Color _panel = Color(0xFF0D1B29);
  static const Color _panelAlt = Color(0xFF10273A);
  static const Color _line = Color(0xFF1E4A67);
  static const Color _primary = Color(0xFF3FFFD7);
  static const Color _secondary = Color(0xFF5AB2FF);
  static const Color _danger = Color(0xFFFF5C8A);
  static const Color _text = Color(0xFFF2F7FB);
  static const Color _muted = Color(0xFF93AABF);

  static ThemeData get darkTheme {
    final ColorScheme scheme = ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _panel,
      error: _danger,
      onPrimary: _bg,
      onSecondary: _bg,
      onSurface: _text,
      onError: _text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,
      fontFamily: 'monospace',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 38,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: _text,
          letterSpacing: -1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: _text,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _text,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: _text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: _muted),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _bg,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: _line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _panelAlt.withValues(alpha: 0.72),
        hintStyle: const TextStyle(color: _muted),
        labelStyle: const TextStyle(color: _muted),
        prefixIconColor: _primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _danger, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _panel,
        contentTextStyle: const TextStyle(color: _text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: _line,
      cardTheme: CardThemeData(
        color: _panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
