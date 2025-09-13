import 'package:flutter/material.dart';

class Category {
  final String id;
  final String nameKey; // Clé pour l'internationalisation
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Catégories prédéfinies
class ProductCategories {
  static const Category fridge = Category(
    id: 'fridge',
    nameKey: 'category_fridge',
    icon: Icons.kitchen,
    color: Colors.blue,
  );

  static const Category pantry = Category(
    id: 'pantry',
    nameKey: 'category_pantry',
    icon: Icons.inventory_2,
    color: Colors.orange,
  );

  static const Category freezer = Category(
    id: 'freezer',
    nameKey: 'category_freezer',
    icon: Icons.ac_unit,
    color: Colors.lightBlue,
  );

  static const Category other = Category(
    id: 'other',
    nameKey: 'category_other',
    icon: Icons.more_horiz,
    color: Colors.grey,
  );

  static const List<Category> all = [
    fridge,
    pantry,
    freezer,
    other,
  ];

  static Category? getById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Alias pour compatibilité
  static Category? getCategoryById(String id) {
    return getById(id);
  }
}