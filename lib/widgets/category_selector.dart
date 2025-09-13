import 'package:flutter/material.dart';
import '../models/category.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final bool showAllOption;
  final String? allOptionText;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showAllOption = true,
    this.allOptionText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingS),
      child: Row(
        children: [
          // Option "Toutes les catégories"
          if (showAllOption)
            _CategoryChip(
              label: allOptionText ?? 'Toutes',
              icon: Icons.all_inclusive,
              color: AppColors.primary,
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            ),
          
          if (showAllOption)
            const SizedBox(width: AppStyles.paddingS),
          
          // Catégories
          ...ProductCategories.all.map((category) => Padding(
            padding: const EdgeInsets.only(right: AppStyles.paddingS),
            child: _CategoryChip(
              label: _getCategoryName(category),
              icon: category.icon,
              color: category.color,
              isSelected: selectedCategory == category.id,
              onTap: () => onCategorySelected(category.id),
            ),
          )),
        ],
      ),
    );
  }

  String _getCategoryName(Category category) {
    // Dans une vraie app, vous utiliseriez l'internationalisation ici
    switch (category.id) {
      case 'fridge':
        return 'Frigo';
      case 'pantry':
        return 'Placard';
      case 'freezer':
        return 'Congélateur';
      case 'other':
        return 'Autre';
      default:
        return 'Autre';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingS,
          vertical: AppStyles.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? color 
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
          border: Border.all(
            color: isSelected 
                ? color 
                : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [AppStyles.shadowS] 
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppStyles.iconS,
              color: isSelected 
                  ? Colors.white 
                  : color,
            ),
            const SizedBox(width: AppStyles.paddingXS),
            Flexible(
              child: Text(
                label,
                style: AppStyles.labelMedium(context).copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : color,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}