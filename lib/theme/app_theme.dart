import 'package:flutter/material.dart';

/// Material 3 Blue 默认配色
class AnxColors {
  static const primary = Color(0xFF1565C0);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFD1E4FF);
  static const onPrimaryContainer = Color(0xFF001D36);
  static const secondary = Color(0xFF535F70);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceDark = Color(0xFF111318);
  static const error = Color(0xFFBA1A1A);
  static const muted = Color(0xFF74777F);
  static const banned = Color(0xFF9E9E9E);
}

ThemeData buildAnLuaTheme({bool dark = true}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AnxColors.primary,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? AnxColors.surfaceDark : AnxColors.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: dark ? AnxColors.surfaceDark : AnxColors.surface,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: scheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
