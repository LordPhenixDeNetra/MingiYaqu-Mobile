import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF2E7D32); // Vert principal
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  // Couleurs secondaires
  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color secondaryLight = Color(0xFFFFCC02);
  static const Color secondaryDark = Color(0xFFE65100);
  
  // Couleurs d'état des produits
  static const Color fresh = Color(0xFF4CAF50); // Vert - produit frais
  static const Color expiringSoon = Color(0xFFFF9800); // Orange - expire bientôt
  static const Color expired = Color(0xFFF44336); // Rouge - expiré
  
  // Couleurs de fond
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Couleurs de texte
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  // Couleurs utilitaires
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFF79747E);
  static const Color shadow = Color(0xFF000000);
  
  // Couleurs pour le mode sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  
  // Couleurs des catégories
  static const Color categoryFridge = Color(0xFF2196F3);
  static const Color categoryPantry = Color(0xFFFF9800);
  static const Color categoryFreezer = Color(0xFF03DAC6);
  static const Color categoryOther = Color(0xFF9E9E9E);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient freshGradient = LinearGradient(
    colors: [fresh, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient expiringSoonGradient = LinearGradient(
    colors: [expiringSoon, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient expiredGradient = LinearGradient(
    colors: [expired, Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}