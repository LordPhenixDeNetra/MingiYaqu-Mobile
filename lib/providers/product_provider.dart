import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
// import '../models/category.dart';

class ProductProvider extends ChangeNotifier {
  static const String _boxName = 'products';
  Box<Product>? _box;
  List<Product> _products = [];
  String _searchQuery = '';
  String? _selectedCategory;
  ProductSortType _sortType = ProductSortType.expirationDate;
  bool _showExpiredOnly = false;
  bool _showExpiringSoonOnly = false;
  bool _isLoading = false;

  // Getters
  List<Product> get products => _getFilteredAndSortedProducts();
  List<Product> get allProducts => _products;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  ProductSortType get sortType => _sortType;
  bool get showExpiredOnly => _showExpiredOnly;
  bool get showExpiringSoonOnly => _showExpiringSoonOnly;
  bool get isLoading => _isLoading;

  // Statistiques
  int get totalProducts => _products.length;
  int get expiredProducts => _products.where((p) => p.expirationStatus == ExpirationStatus.expired).length;
  int get expiringSoonProducts => _products.where((p) => p.expirationStatus == ExpirationStatus.expiringSoon).length;
  int get freshProducts => _products.where((p) => p.expirationStatus == ExpirationStatus.fresh).length;

  // Initialisation
  Future<void> init() async {
    try {
      _box = await Hive.openBox<Product>(_boxName);
      _loadProducts();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du ProductProvider: $e');
    }
  }

  // Méthode d'initialisation pour MultiProvider
  Future<void> initialize() async {
    await init();
  }

  void _loadProducts() {
    if (_box != null) {
      _products = _box!.values.toList();
      notifyListeners();
    }
  }

  // CRUD Operations
  Future<void> addProduct(Product product) async {
    try {
      await _box?.put(product.id, product);
      _products.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du produit: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _box?.put(product.id, product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du produit: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _box?.delete(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du produit: $e');
      rethrow;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtrage et recherche
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortType(ProductSortType sortType) {
    _sortType = sortType;
    notifyListeners();
  }

  void setShowExpiredOnly(bool show) {
    _showExpiredOnly = show;
    if (show) _showExpiringSoonOnly = false;
    notifyListeners();
  }

  void setShowExpiringSoonOnly(bool show) {
    _showExpiringSoonOnly = show;
    if (show) _showExpiredOnly = false;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _showExpiredOnly = false;
    _showExpiringSoonOnly = false;
    notifyListeners();
  }

  List<Product> _getFilteredAndSortedProducts() {
    List<Product> filtered = List.from(_products);

    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
               (product.notes?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Filtrage par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Filtrage par statut d'expiration
    if (_showExpiredOnly) {
      filtered = filtered.where((product) => product.expirationStatus == ExpirationStatus.expired).toList();
    } else if (_showExpiringSoonOnly) {
      filtered = filtered.where((product) => product.expirationStatus == ExpirationStatus.expiringSoon).toList();
    }

    // Tri
    filtered.sort((a, b) {
      switch (_sortType) {
        case ProductSortType.name:
          return a.name.compareTo(b.name);
        case ProductSortType.expirationDate:
          return a.expirationDate.compareTo(b.expirationDate);
        case ProductSortType.purchaseDate:
          return b.purchaseDate.compareTo(a.purchaseDate);
        case ProductSortType.category:
          final categoryComparison = a.category.compareTo(b.category);
          if (categoryComparison == 0) {
            return a.expirationDate.compareTo(b.expirationDate);
          }
          return categoryComparison;
      }
    });

    return filtered;
  }

  // Obtenir les produits par catégorie
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Obtenir les produits expirant dans X jours
  List<Product> getProductsExpiringInDays(int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    return _products.where((product) {
      final daysUntilExpiration = product.daysUntilExpiration;
      return daysUntilExpiration >= 0 && daysUntilExpiration <= days;
    }).toList();
  }

  // Recharger les produits
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _loadProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir les statistiques
  Map<String, int> getStatistics() {
    return {
      'total': totalProducts,
      'expired': expiredProducts,
      'expiringSoon': expiringSoonProducts,
      'fresh': freshProducts,
    };
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}

enum ProductSortType {
  name,
  expirationDate,
  purchaseDate,
  category,
}