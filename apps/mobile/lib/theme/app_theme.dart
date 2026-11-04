import 'package:flutter/material.dart';

const Color _seedColor = Color(0xFF2E7D32);

ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  final isLight = brightness == Brightness.light;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: isLight ? const Color(0xFFF1F8F1) : null,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1B5E20),
      indicatorColor: const Color(0xFFA5D6A7),
      iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? const Color(0xFF1B5E20)
              : Colors.white70,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: StadiumBorder(),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);