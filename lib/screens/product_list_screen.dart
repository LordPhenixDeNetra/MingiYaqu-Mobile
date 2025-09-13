import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/page_transitions.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialFilter;
  final String? initialCategory;

  const ProductListScreen({
    super.key,
    this.initialFilter,
    this.initialCategory,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  ProductSortType _sortType = ProductSortType.expirationDate;
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _statusFilter = widget.initialFilter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildSortOptions(),
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mes Produits'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: Icon(
            Icons.filter_list,
            color: _hasActiveFilters() ? AppColors.secondary : AppColors.onPrimary,
          ),
        ),
        PopupMenuButton<ProductSortType>(
          icon: const Icon(Icons.sort),
          onSelected: (sortType) {
            setState(() {
              _sortType = sortType;
            });
            context.read<ProductProvider>().setSortType(sortType);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ProductSortType.name,
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha),
                  SizedBox(width: 8),
                  Text('Nom'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ProductSortType.expirationDate,
              child: Row(
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text('Date d\'expiration'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ProductSortType.purchaseDate,
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text('Date d\'achat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ProductSortType.category,
              child: Row(
                children: [
                  Icon(Icons.category),
                  SizedBox(width: 8),
                  Text('Catégorie'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SearchField(
              hint: 'Rechercher un produit...',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          const SizedBox(height: AppStyles.paddingL),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.paddingM,
              vertical: AppStyles.paddingS,
            ),
            child: CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (categoryId) {
                setState(() {
                  _selectedCategory = categoryId;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.paddingL),
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingS),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: Icon(
              Icons.sort,
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
                  'Tri actuel',
                  style: AppStyles.labelSmall(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getSortTypeName(_sortType),
                  style: AppStyles.labelMedium(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Effacer'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredProducts = _getFilteredProducts(productProvider.products);

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildResultsHeader(filteredProducts.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppStyles.paddingL),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return AnimatedListItem(
                    index: index,
                    delay: const Duration(milliseconds: 80),
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppStyles.paddingM,
                      ),
                      child: ProductCard(
                        product: product,
                        onTap: () => _navigateToProductDetail(product),
                        onEdit: () => _editProduct(product),
                        onDelete: () => _deleteProduct(product),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingL,
        vertical: AppStyles.paddingS,
      ),
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.03),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingS),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
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
                  'Résultats',
                  style: AppStyles.labelSmall(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$count produit${count > 1 ? 's' : ''} trouvé${count > 1 ? 's' : ''}',
                  style: AppStyles.titleSmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.paddingM,
                vertical: AppStyles.paddingS,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: AppStyles.paddingXS),
                  Text(
                    'Filtré',
                    style: AppStyles.labelSmall(context).copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _hasActiveFilters() ? Icons.search_off : Icons.inventory_2_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppStyles.paddingXL),
            Text(
              _hasActiveFilters() ? 'Aucun résultat' : 'Aucun produit',
              style: AppStyles.headingM(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppStyles.paddingM),
            Text(
              _hasActiveFilters()
                  ? 'Essayez de modifier vos critères de recherche'
                  : 'Commencez par ajouter votre premier produit',
              style: AppStyles.bodyMedium(context).copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.paddingXL),
            if (_hasActiveFilters())
              SecondaryButton(
                text: 'Effacer les filtres',
                icon: Icons.clear_all,
                onPressed: _clearAllFilters,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un produit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingXL,
                      vertical: AppStyles.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusL),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered = products;

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (product.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (product.barcode?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Filtrer par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }

    // Filtrer par statut
    if (_statusFilter != null) {
      filtered = filtered.where((product) {
        switch (_statusFilter) {
          case 'expired':
            return product.getExpirationStatus() == ExpirationStatus.expired;
          case 'expiring':
            return product.getExpirationStatus() == ExpirationStatus.expiringSoon;
          case 'fresh':
            return product.getExpirationStatus() == ExpirationStatus.fresh;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
           _selectedCategory != null ||
           _statusFilter != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _statusFilter = null;
      _searchController.clear();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyles.radiusL),
        ),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedStatus: _statusFilter,
        onStatusChanged: (status) {
          setState(() {
            _statusFilter = status;
          });
        },
      ),
    );
  }

  String _getSortTypeName(ProductSortType sortType) {
    switch (sortType) {
      case ProductSortType.name:
        return 'Nom';
      case ProductSortType.expirationDate:
        return 'Date d\'expiration';
      case ProductSortType.purchaseDate:
        return 'Date d\'achat';
      case ProductSortType.category:
        return 'Catégorie';
    }
  }

  void _navigateToAddProduct() {
    Navigator.of(context).pushSlideBottom(
      const AddProductScreen(),
    );
  }

  void _editProduct(Product product) {
    Navigator.of(context).pushSlideBottom(
      AddProductScreen(product: product),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${product.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${product.name}" supprimé'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
          product: product,
          onEdit: () => _editProduct(product),
          onDelete: () => _deleteProduct(product),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedStatus;
  final Function(String?) onStatusChanged;

  const _FilterBottomSheet({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _tempStatus;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrer par statut',
                style: AppStyles.titleLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingL),
          _buildStatusOption(null, 'Tous les produits', Icons.inventory_2),
          _buildStatusOption('fresh', 'Produits frais', Icons.check_circle),
          _buildStatusOption('expiring', 'Expire bientôt', Icons.warning_amber),
          _buildStatusOption('expired', 'Expirés', Icons.error),
          const SizedBox(height: AppStyles.paddingXL),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Annuler',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppStyles.paddingM),
              Expanded(
                child: PrimaryButton(
                  text: 'Appliquer',
                  onPressed: () {
                    widget.onStatusChanged(_tempStatus);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String? value, String label, IconData icon) {
    final isSelected = _tempStatus == value;
    final color = _getStatusColor(value);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? color : AppColors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: AppStyles.bodyLarge(context).copyWith(
          color: isSelected ? color : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: color,
            )
          : null,
      onTap: () {
        setState(() {
          _tempStatus = value;
        });
      },
      selected: isSelected,
      selectedTileColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'fresh':
        return AppColors.success;
      case 'expiring':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}