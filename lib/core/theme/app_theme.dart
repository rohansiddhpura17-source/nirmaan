import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryNavy,
      onPrimary: AppColors.textOnNavy,
      primaryContainer: AppColors.primaryBlueSubtle,
      onPrimaryContainer: AppColors.primaryBlueDark,
      secondary: AppColors.secondaryAmber,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryAmberLight,
      onSecondaryContainer: AppColors.secondaryAmberDark,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceSubtle,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.errorRed,
      onError: Colors.white,
      outline: AppColors.surfaceBorder,
      outlineVariant: AppColors.divider,
      shadow: AppColors.primaryNavy.withValues(alpha: 0.08),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Inter',

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textOnNavy,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnNavy,
          letterSpacing: -0.2,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderLg,
          side: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderMd,
          ),
          elevation: 0,
          textStyle: AppTypography.button,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderMd,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderSm,
          ),
          textStyle:
              AppTypography.button.copyWith(color: AppColors.primaryBlue),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space14,
        ),
        hintStyle:
            AppTypography.bodySecondary.copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.bodySecondary,
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.borderMd,
          borderSide: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderMd,
          borderSide: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderMd,
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderMd,
          borderSide: BorderSide(color: AppColors.errorRed, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderMd,
          borderSide: BorderSide(color: AppColors.errorRed, width: 1.8),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
