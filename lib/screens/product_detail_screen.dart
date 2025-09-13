import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/category_icon.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = ProductCategories.getById(widget.product.category);
    final expirationColor = _getExpirationColor();
    final daysText = _getDaysText();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, category, expirationColor),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpirationCard(context, daysText, expirationColor),
                      const SizedBox(height: AppStyles.paddingL),
                      if (widget.product.imagePath?.isNotEmpty == true) ...[
                        _buildImageCard(context),
                        const SizedBox(height: AppStyles.paddingL),
                      ],
                      _buildProductInfoCard(context, category),
                      const SizedBox(height: AppStyles.paddingL),
                      _buildDatesCard(context),
                      if (widget.product.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: AppStyles.paddingL),
                        _buildNotesCard(context),
                      ],
                      if (widget.product.barcode?.isNotEmpty == true) ...[
                        const SizedBox(height: AppStyles.paddingL),
                        _buildBarcodeCard(context),
                      ],
                      const SizedBox(height: AppStyles.paddingXL),
                      _buildActionButtons(context),
                      const SizedBox(height: AppStyles.paddingXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Category? category, Color statusColor) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'category_${widget.product.id}',
                        child: Container(
                          padding: const EdgeInsets.all(AppStyles.paddingL),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.2),
                                (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                            border: Border.all(
                              color: (category?.color ?? AppColors.onSurfaceVariant).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            category?.icon ?? Icons.inventory,
                            size: AppStyles.iconL,
                            color: category?.color ?? AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppStyles.paddingL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'name_${widget.product.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.product.name,
                                  style: AppStyles.headlineMedium(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppStyles.paddingS),
                            Text(
                              _getCategoryName(category),
                              style: AppStyles.titleMedium(context).copyWith(
                                color: category?.color ?? AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpirationCard(BuildContext context, String daysText, Color statusColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.15),
                    statusColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingL),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                    ),
                    child: Icon(
                      _getExpirationIcon(),
                      size: AppStyles.iconL,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'État d\'expiration',
                          style: AppStyles.labelLarge(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppStyles.paddingS),
                        Text(
                          daysText,
                          style: AppStyles.headlineSmall(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppStyles.paddingS),
                        Text(
                          'Expire le ${widget.product.formattedExpirationDate}',
                          style: AppStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildProductInfoCard(BuildContext context, Category? category) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations du produit',
                    style: AppStyles.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingL),
                  _buildInfoRow(
                    context,
                    Icons.inventory_2_outlined,
                    'Quantité',
                    '${widget.product.quantity}',
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppStyles.paddingM),
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    'Catégorie',
                    _getCategoryName(category),
                    category?.color ?? AppColors.onSurfaceVariant,
                  ),
                  if (widget.product.location?.isNotEmpty == true) ...[
                    const SizedBox(height: AppStyles.paddingM),
                    _buildInfoRow(
                      context,
                      Icons.location_on_outlined,
                      'Emplacement',
                      widget.product.location!,
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatesCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dates importantes',
                    style: AppStyles.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingL),
                  _buildInfoRow(
                    context,
                    Icons.shopping_cart_outlined,
                    'Date d\'achat',
                    widget.product.formattedPurchaseDate,
                    AppColors.fresh,
                  ),
                  const SizedBox(height: AppStyles.paddingM),
                  _buildInfoRow(
                    context,
                    Icons.schedule_outlined,
                    'Date d\'expiration',
                    widget.product.formattedExpirationDate,
                    _getExpirationColor(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.paddingM),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                        ),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: AppStyles.iconM,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppStyles.paddingM),
                      Text(
                        'Notes',
                        style: AppStyles.titleLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.paddingL),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppStyles.paddingL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.product.notes!,
                      style: AppStyles.bodyLarge(context).copyWith(
                        height: 1.5,
                        fontWeight: FontWeight.w500,
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

  Widget _buildBarcodeCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 70 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.paddingM),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                        ),
                        child: Icon(
                          Icons.qr_code_outlined,
                          size: AppStyles.iconM,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: AppStyles.paddingM),
                      Text(
                        'Code-barres',
                        style: AppStyles.titleLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.paddingL),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.product.barcode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Code-barres copié dans le presse-papiers'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppStyles.paddingL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.barcode!,
                              style: AppStyles.bodyLarge(context).copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.copy_outlined,
                            size: AppStyles.iconS,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
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

  Widget _buildActionButtons(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 80 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                if (widget.onEdit != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit?.call();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.paddingL,
                          horizontal: AppStyles.paddingXL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                if (widget.onEdit != null && widget.onDelete != null)
                  const SizedBox(width: AppStyles.paddingM),
                if (widget.onDelete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expired,
                        side: BorderSide(color: AppColors.expired),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.paddingL,
                          horizontal: AppStyles.paddingXL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppStyles.paddingM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          ),
          child: Icon(
            icon,
            size: AppStyles.iconM,
            color: color,
          ),
        ),
        const SizedBox(width: AppStyles.paddingL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.labelMedium(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyles.paddingXS),
              Text(
                value,
                style: AppStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${widget.product.name}" ?\n\nCette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
                Navigator.pop(context); // Retourner à la liste
                widget.onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expired,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
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

  Widget _buildImageCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo du produit',
                    style: AppStyles.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingL),
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImagePreview(context),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                          maxHeight: 200,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                          child: Image.file(
                            File(widget.product.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: AppStyles.iconL,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: AppStyles.paddingS),
                                    Text(
                                      'Image non disponible',
                                      style: AppStyles.bodySmall(context).copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingM),
                  Center(
                    child: Text(
                      'Appuyez pour voir en grand',
                      style: AppStyles.bodySmall(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                  child: Image.file(
                    File(widget.product.imagePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: AppStyles.iconXL,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppStyles.paddingM),
                            Text(
                              'Image non disponible',
                              style: AppStyles.titleMedium(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getCategoryName(Category? category) {
    if (category == null) return 'Autre';
    
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