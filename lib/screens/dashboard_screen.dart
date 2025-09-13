import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/page_transitions.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedCategory;
  bool _showPermissionBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      _checkNotificationPermissions();
    });
  }

  Future<void> _checkNotificationPermissions() async {
    final notificationProvider = context.read<NotificationProvider>();
    final hasPermission = await notificationProvider.checkPermissions();
    final isEnabled = notificationProvider.settings.isEnabled;
    
    if (mounted && isEnabled && !hasPermission) {
      setState(() {
        _showPermissionBanner = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_showPermissionBanner) _buildPermissionBanner(),
              _buildHeader(),
              _buildStatsCards(),
              _buildCategoryFilter(),
              _buildProductsList(),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Bonjour';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
      greetingIcon = Icons.wb_sunny;
    } else {
      greeting = 'Bonsoir';
      greetingIcon = Icons.nights_stay_outlined;
    }

    return Container(
      margin: const EdgeInsets.all(AppStyles.paddingM),
      padding: const EdgeInsets.all(AppStyles.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            greetingIcon,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: AppStyles.iconM,
                          ),
                          const SizedBox(width: AppStyles.paddingS),
                          Flexible(
                            child: Text(
                              greeting,
                              style: AppStyles.titleLarge(context).copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.paddingXS),
                      Text(
                        'MingiYaqu',
                        style: AppStyles.headlineMedium(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                      icon: Icon(
                        context.watch<ThemeProvider>().isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'Changer le thème',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushFadeScale(
                          const SettingsScreen(),
                        );
                      },
                      icon: Icon(
                        Icons.settings_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'Paramètres',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingL),
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: AppStyles.iconM,
                ),
                const SizedBox(width: AppStyles.paddingM),
                Expanded(
                  child: Text(
                    'Gérez vos produits alimentaires intelligemment',
                    style: AppStyles.bodyLarge(context).copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;
        final totalProducts = products.length;
        final now = DateTime.now();
        final freshProducts = products.where((p) => p.expirationDate.isAfter(now.add(const Duration(days: 7)))).length;
        final expiringProducts = products.where((p) => p.expirationDate.isAfter(now) && p.expirationDate.isBefore(now.add(const Duration(days: 7)))).length;
        final expiredProducts = products.where((p) => p.expirationDate.isBefore(now)).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingM),
          child: Column(
            children: [
              // Première ligne - Statistique principale
              _buildMainStatCard(totalProducts),
              const SizedBox(height: AppStyles.paddingM),
              // Deuxième ligne - Statistiques détaillées
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildDetailStatCard(
                        title: 'Frais',
                        value: freshProducts,
                        total: totalProducts,
                        icon: Icons.check_circle_rounded,
                        color: AppColors.fresh,
                        onTap: () => _navigateToProductList(filter: 'fresh'),
                      ),
                    ),
                    const SizedBox(width: AppStyles.paddingS),
                    Expanded(
                      flex: 1,
                      child: _buildDetailStatCard(
                        title: 'À surveiller',
                        value: expiringProducts,
                        total: totalProducts,
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.expiringSoon,
                        onTap: () => _navigateToProductList(filter: 'expiring'),
                      ),
                    ),
                    const SizedBox(width: AppStyles.paddingS),
                    Expanded(
                      flex: 1,
                      child: _buildDetailStatCard(
                        title: 'Expirés',
                        value: expiredProducts,
                        total: totalProducts,
                        icon: Icons.error_rounded,
                        color: AppColors.expired,
                        onTap: () => _navigateToProductList(filter: 'expired'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainStatCard(int totalProducts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.paddingXL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: AppStyles.iconL,
                ),
              ),
              const SizedBox(width: AppStyles.paddingL),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalProducts.toString(),
                    style: AppStyles.displaySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    totalProducts <= 1 ? 'Produit total' : 'Produits totaux',
                    style: AppStyles.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: InkWell(
              onTap: () => _navigateToProductList(),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.paddingS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voir tous les produits',
                      style: AppStyles.titleSmall(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppStyles.paddingS),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: AppStyles.iconS,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatCard({
    required String title,
    required int value,
    required int total,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.paddingS),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: AppStyles.iconM,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppStyles.bodySmall(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingM),
            Text(
              value.toString(),
              style: AppStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppStyles.paddingXS),
            Text(
              title,
              style: AppStyles.bodySmall(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: AppStyles.paddingS),
            // Barre de progression
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: total > 0 ? value / total : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catégories',
                style: AppStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _navigateToProductList,
                child: Text(
                  'Voir tout',
                  style: AppStyles.labelLarge(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppStyles.paddingS),
        CategorySelector(
          selectedCategory: _selectedCategory,
          onCategorySelected: (categoryId) {
            setState(() {
              _selectedCategory = categoryId;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = _selectedCategory == null
            ? productProvider.products
            : productProvider.getProductsByCategory(_selectedCategory!);

        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (products.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingL),
              child: Text(
                _selectedCategory == null
                    ? 'Produits récents'
                    : 'Produits - ${_getCategoryName(_selectedCategory!)}',
                style: AppStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingL),
              itemCount: products.length > 5 ? 5 : products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppStyles.paddingM),
                  child: AnimatedListItem(
                    index: index,
                    delay: const Duration(milliseconds: 100),
                    slideFromBottom: true,
                    fadeIn: true,
                    scaleIn: true,
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
            if (products.length > 5)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingL),
                  child: SecondaryButton(
                    text: 'Voir tous les produits (${products.length})',
                    onPressed: _navigateToProductList,
                    fullWidth: true,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppStyles.paddingL),
            Text(
              _selectedCategory == null
                  ? 'Aucun produit'
                  : 'Aucun produit dans cette catégorie',
              style: AppStyles.titleMedium(context).copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.paddingS),
            Text(
              'Commencez par ajouter vos premiers produits alimentaires',
              style: AppStyles.bodyMedium(context).copyWith(
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.paddingXL),
            PrimaryButton(
              text: 'Ajouter un produit',
              icon: Icons.add,
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
            ),
          ],
        ),
      ),
    );
  }



  void _navigateToProductList({String? filter}) {
    Navigator.of(context).pushSlideRight(
      ProductListScreen(
        initialFilter: filter,
        initialCategory: _selectedCategory,
      ),
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

  Widget _buildPermissionBanner() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.paddingM),
      padding: const EdgeInsets.all(AppStyles.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.errorContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_off_outlined,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Permissions de notifications requises',
                  style: AppStyles.titleSmall(context).copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showPermissionBanner = false;
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Les notifications sont activées mais l\'autorisation système est manquante. Vous ne recevrez pas d\'alertes d\'expiration.',
            style: AppStyles.bodySmall(context).copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPermissionBanner = false;
                  });
                },
                child: Text(
                  'Ignorer',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final notificationProvider = context.read<NotificationProvider>();
                  final granted = await notificationProvider.requestPermissions();
                  if (granted) {
                    setState(() {
                      _showPermissionBanner = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Permissions accordées ! Les notifications sont maintenant actives.'),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Permissions refusées. Activez-les manuellement dans les paramètres.'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Autoriser'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final category = ProductCategories.getById(categoryId);
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