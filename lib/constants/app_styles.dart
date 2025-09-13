import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Espacements
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Rayons de bordure
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;
  
  // Élévations
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // Tailles d'icônes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Styles de texte dynamiques
  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle displayMedium(BuildContext context) => TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle displaySmall(BuildContext context) => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle headingM(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle headingS(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle headlineMedium(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle headlineSmall(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle titleSmall(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onBackground,
  );
  
  static TextStyle labelMedium(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  // Styles spéciaux
  static TextStyle productName(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle productCategory(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  static TextStyle expirationDate(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle buttonText(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onPrimary,
  );
  
  // Ombres
  static const BoxShadow shadowS = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  static const BoxShadow shadowM = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );
  
  static const BoxShadow shadowL = BoxShadow(
    color: Color(0x24000000),
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );
  
  // Bordures
  static const BorderRadius borderRadiusSOld = BorderRadius.all(Radius.circular(radiusS));
  static const BorderRadius borderRadiusMOld = BorderRadius.all(Radius.circular(radiusM));
  static const BorderRadius borderRadiusLOld = BorderRadius.all(Radius.circular(radiusL));
  static const BorderRadius borderRadiusXLOld = BorderRadius.all(Radius.circular(radiusXL));
  
  // Styles de conteneur
  static const BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: borderRadiusMOld,
    boxShadow: [shadowS],
  );
  
  static const BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: borderRadiusMOld,
    boxShadow: [shadowM],
  );
}