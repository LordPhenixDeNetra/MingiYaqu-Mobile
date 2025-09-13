import 'package:flutter/material.dart';
import '../models/category.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

enum CategoryIconSize {
  small,
  medium,
  large,
}

class CategoryIcon extends StatelessWidget {
  final Category category;
  final CategoryIconSize size;
  final bool showBackground;
  final bool showBorder;
  final VoidCallback? onTap;
  final Color? customColor;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = CategoryIconSize.medium,
    this.showBackground = true,
    this.showBorder = false,
    this.onTap,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = _getIconSize();
    final containerSize = _getContainerSize();
    final color = customColor ?? category.color;

    Widget iconWidget = Icon(
      category.icon,
      size: iconSize,
      color: showBackground ? Colors.white : color,
    );

    if (!showBackground && !showBorder) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: iconWidget)
          : iconWidget;
    }

    Widget container = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: showBackground ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(containerSize / 2),
        border: showBorder
            ? Border.all(
                color: color,
                width: 2,
              )
            : null,
        boxShadow: showBackground
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: iconWidget),
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: container,
          )
        : container;
  }

  double _getIconSize() {
    switch (size) {
      case CategoryIconSize.small:
        return AppStyles.iconS;
      case CategoryIconSize.medium:
        return AppStyles.iconM;
      case CategoryIconSize.large:
        return AppStyles.iconL;
    }
  }

  double _getContainerSize() {
    switch (size) {
      case CategoryIconSize.small:
        return 32;
      case CategoryIconSize.medium:
        return 48;
      case CategoryIconSize.large:
        return 64;
    }
  }
}

// Widget pour afficher une liste d'icônes de catégories
class CategoryIconGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(Category) onCategorySelected;
  final CategoryIconSize iconSize;
  final int crossAxisCount;
  final double spacing;

  const CategoryIconGrid({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.selectedCategoryId,
    this.iconSize = CategoryIconSize.medium,
    this.crossAxisCount = 4,
    this.spacing = AppStyles.paddingM,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategoryId == category.id;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(
              category: category,
              size: iconSize,
              showBackground: isSelected,
              showBorder: !isSelected,
              onTap: () => onCategorySelected(category),
            ),
            const SizedBox(height: AppStyles.paddingXS),
            Text(
              _getCategoryName(category),
              style: AppStyles.labelSmall(context).copyWith(
                color: isSelected
                    ? category.color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
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

// Widget pour sélectionner une catégorie avec un style de liste
class CategoryListTile extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CategoryIcon(
        category: category,
        size: CategoryIconSize.medium,
        showBackground: isSelected,
        showBorder: !isSelected,
      ),
      title: Text(
        _getCategoryName(category),
        style: AppStyles.bodyLarge(context).copyWith(
          color: isSelected
              ? category.color
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          (isSelected
              ? Icon(
                  Icons.check_circle,
                  color: category.color,
                )
              : null),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: category.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
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