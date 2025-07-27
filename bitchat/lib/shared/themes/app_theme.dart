import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Application theme configuration following Material Design 3
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF1976D2),
      primaryContainer: Color(0xFFE3F2FD),
      secondary: Color(0xFF03DAC6),
      secondaryContainer: Color(0xFFE0F7FA),
      surface: Color(0xFFFFFBFE),
      surfaceContainerHighest: Color(0xFFE6E0E9),
      error: Color(0xFFBA1A1A),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFF1C1B1F),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.smallPadding),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        ),
        elevation: 8,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius * 2),
          ),
        ),
        elevation: 8,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      primaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF80CBC4),
      secondaryContainer: Color(0xFF00695C),
      surface: Color(0xFF121212),
      surfaceContainerHighest: Color(0xFF2D2D2D),
      error: Color(0xFFCF6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE1E2E1),
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.smallPadding),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        ),
        elevation: 8,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius * 2),
          ),
        ),
        elevation: 8,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    );
  }
}
