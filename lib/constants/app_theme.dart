import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  // Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        outline: AppColors.outline,
        shadow: AppColors.shadow,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),
      
      // Cards
      cardTheme: const CardTheme(
        color: AppColors.surface,
        elevation: AppStyles.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
        ),
      ),
      
      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: AppStyles.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.paddingL,
            vertical: AppStyles.paddingM,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Boutons de texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.paddingM,
            vertical: AppStyles.paddingS,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusS)),
          ),
        ),
      ),
      
      // Boutons d'icône
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          padding: const EdgeInsets.all(AppStyles.paddingS),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppStyles.paddingM,
          vertical: AppStyles.paddingM,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppStyles.elevationM,
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: AppStyles.elevationS,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkOnBackground,
        outline: AppColors.darkOutline,
        shadow: AppColors.shadow,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),
      
      // Cards
      cardTheme: const CardTheme(
        color: AppColors.darkSurface,
        elevation: AppStyles.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
        ),
      ),
      
      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimary,
          elevation: AppStyles.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.paddingL,
            vertical: AppStyles.paddingM,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppStyles.borderRadiusM)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppStyles.paddingM,
          vertical: AppStyles.paddingM,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimary,
        elevation: AppStyles.elevationM,
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: AppStyles.elevationS,
      ),
    );
  }
}