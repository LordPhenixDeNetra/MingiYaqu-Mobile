import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final category = ProductCategories.getById(widget.product.category);
    final expirationColor = _getExpirationColor();
    final daysText = _getDaysText();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppStyles.paddingM,
              vertical: AppStyles.paddingS,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
              boxShadow: [
                BoxShadow(
                  color: expirationColor.withOpacity(0.15),
                  blurRadius: _elevationAnimation.value + 2,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                  blurRadius: _elevationAnimation.value * 2,
                  offset: Offset(0, _elevationAnimation.value),
                ),
              ],
              border: Border.all(
                color: expirationColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // En-tête avec nom et actions
              _buildHeader(context, category, expirationColor),
              
              const SizedBox(height: AppStyles.paddingM),
              
              // Informations sur l'expiration
              _buildExpiryInfo(context, widget.product.daysUntilExpiration, daysText, expirationColor),
              
              // Informations supplémentaires
               const SizedBox(height: AppStyles.paddingM),
               _buildProductInfo(context),
               
               // Notes (si présentes)
               if (widget.product.notes?.isNotEmpty == true) ...[
                 const SizedBox(height: AppStyles.paddingM),
                 _buildNotes(context),
               ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      if (widget.onEdit != null)
        IconButton(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.edit_outlined),
          iconSize: AppStyles.iconS,
          padding: const EdgeInsets.all(AppStyles.paddingXS),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      if (widget.onDelete != null)
        IconButton(
          onPressed: widget.onDelete,
          icon: const Icon(Icons.delete_outline),
          iconSize: AppStyles.iconS,
          padding: const EdgeInsets.all(AppStyles.paddingXS),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
    ];
  }

  Color _getExpirationColor() {
    switch (widget.product.expirationStatus) {
      case ExpirationStatus.fresh:
        return AppColors.fresh;
      case ExpirationStatus.expiringSoon:
        return AppColors.expiringSoon;
      case ExpirationStatus.expired:
        return AppColors.expired;
    }
  }

  IconData _getExpirationIcon() {
    switch (widget.product.expirationStatus) {
      case ExpirationStatus.fresh:
        return Icons.check_circle_outline;
      case ExpirationStatus.expiringSoon:
        return Icons.warning_outlined;
      case ExpirationStatus.expired:
        return Icons.error_outline;
    }
  }

  String _getDaysText() {
    final days = widget.product.daysUntilExpiration;
    
    if (days < 0) {
      final expiredDays = -days;
      return expiredDays == 1 
          ? 'Expiré depuis 1 jour'
          : 'Expiré depuis $expiredDays jours';
    } else if (days == 0) {
      return 'Expire aujourd\'hui';
    } else if (days == 1) {
      return 'Expire demain';
    } else {
      return 'Expire dans $days jours';
    }
  }

  Widget _buildHeader(BuildContext context, Category? category, Color statusColor) {
    return Row(
      children: [
        // Icône de catégorie avec animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.15),
                      (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                  border: Border.all(
                    color: (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  category?.icon ?? Icons.inventory,
                  size: AppStyles.iconM,
                  color: category?.color ?? AppColors.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: AppStyles.paddingM),
        // Nom du produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: AppStyles.productName(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_getCategoryName(category) != 'Autre')
                Text(
                  _getCategoryName(category),
                  style: AppStyles.productCategory(context).copyWith(
                    color: category?.color ?? AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        // Actions avec animations
        if (widget.showActions)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onEdit != null)
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  onPressed: widget.onEdit!,
                  color: Theme.of(context).colorScheme.primary,
                ),
              if (widget.onDelete != null)
                _buildActionButton(
                  icon: Icons.delete_outline,
                  onPressed: widget.onDelete!,
                  color: AppColors.expired,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            margin: const EdgeInsets.only(left: AppStyles.paddingXS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusS),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon),
              iconSize: AppStyles.iconS,
              color: color,
              padding: const EdgeInsets.all(AppStyles.paddingS),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Row(
      children: [
        if (widget.product.quantity > 1) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.paddingM,
              vertical: AppStyles.paddingS,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: AppStyles.iconXS,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppStyles.paddingXS),
                Text(
                  '${widget.product.quantity}',
                  style: AppStyles.labelSmall(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppStyles.paddingS),
        ],
        if (widget.product.notes?.isNotEmpty ?? false)
           Expanded(
             child: AnimatedContainer(
               duration: const Duration(milliseconds: 300),
               padding: const EdgeInsets.symmetric(
                 horizontal: AppStyles.paddingM,
                 vertical: AppStyles.paddingS,
               ),
               decoration: BoxDecoration(
                 color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                 borderRadius: BorderRadius.circular(AppStyles.radiusM),
                 border: Border.all(
                   color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                   width: 1,
                 ),
               ),
               child: Row(
                 children: [
                   Icon(
                     Icons.note_outlined,
                     size: AppStyles.iconXS,
                     color: Theme.of(context).colorScheme.onSurfaceVariant,
                   ),
                   const SizedBox(width: AppStyles.paddingS),
                   Expanded(
                     child: Text(
                       widget.product.notes!,
                       style: AppStyles.bodySmall(context).copyWith(
                         fontWeight: FontWeight.w500,
                         color: Theme.of(context).colorScheme.onSurfaceVariant,
                       ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                 ],
               ),
             ),
           ),
      ],
    );
  }

  Widget _buildExpiryInfo(BuildContext context, int daysUntilExpiry, String statusText, Color statusColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(AppStyles.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.15),
                    statusColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingS),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadiusS),
                    ),
                    child: Icon(
                      _getExpirationIcon(),
                      size: AppStyles.iconS,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: AppStyles.expirationDate(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppStyles.paddingXS),
                        Text(
                          widget.product.formattedExpirationDate,
                          style: AppStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (daysUntilExpiry <= 7 && daysUntilExpiry > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingM,
                        vertical: AppStyles.paddingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.expiringSoon,
                            AppColors.expiringSoon.withOpacity(0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.expiringSoon.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$daysUntilExpiry j',
                        style: AppStyles.labelSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

   Widget _buildNotes(BuildContext context) {
     return TweenAnimationBuilder<double>(
       duration: const Duration(milliseconds: 500),
       tween: Tween(begin: 0.0, end: 1.0),
       builder: (context, value, child) {
         return Transform.translate(
           offset: Offset(0, 30 * (1 - value)),
           child: Opacity(
             opacity: value,
             child: Container(
               width: double.infinity,
               padding: const EdgeInsets.all(AppStyles.paddingM),
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                     Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 borderRadius: BorderRadius.circular(AppStyles.radiusM),
                 border: Border.all(
                   color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                   width: 1,
                 ),
               ),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(AppStyles.paddingS),
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(AppStyles.radiusS),
                     ),
                     child: Icon(
                       Icons.sticky_note_2_outlined,
                       size: AppStyles.iconS,
                       color: Theme.of(context).colorScheme.primary,
                     ),
                   ),
                   const SizedBox(width: AppStyles.paddingM),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Notes',
                           style: AppStyles.labelMedium(context).copyWith(
                             fontWeight: FontWeight.w600,
                             color: Theme.of(context).colorScheme.primary,
                           ),
                         ),
                         const SizedBox(height: AppStyles.paddingXS),
                         Text(
                           widget.product.notes!,
                           style: AppStyles.bodySmall(context).copyWith(
                             fontWeight: FontWeight.w500,
                             color: Theme.of(context).colorScheme.onSurfaceVariant,
                             height: 1.4,
                           ),
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
           ),
         );
       },
     );
   }

   String _getCategoryName(Category? category) {
    if (category == null) return 'Autre';
    
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