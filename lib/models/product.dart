import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime purchaseDate;

  @HiveField(4)
  DateTime expirationDate;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  String? barcode;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  String? categoryId;

  @HiveField(10)
  String? location;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.purchaseDate,
    required this.expirationDate,
    this.quantity = 1,
    this.imagePath,
    this.barcode,
    this.notes,
    this.categoryId,
    this.location,
  });

  // Calculer le statut d'expiration
  ExpirationStatus get expirationStatus {
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    if (daysUntilExpiration < 0) {
      return ExpirationStatus.expired;
    } else if (daysUntilExpiration <= 2) {
      return ExpirationStatus.expiringSoon;
    } else {
      return ExpirationStatus.fresh;
    }
  }

  // Méthode pour obtenir le statut d'expiration (alias pour compatibilité)
  ExpirationStatus getExpirationStatus() {
    return expirationStatus;
  }

  // Calculer le statut d'expiration (version originale)
  ExpirationStatus get _originalExpirationStatus {
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    if (daysUntilExpiration < 0) {
      return ExpirationStatus.expired;
    } else if (daysUntilExpiration <= 2) {
      return ExpirationStatus.expiringSoon;
    } else {
      return ExpirationStatus.fresh;
    }
  }

  // Obtenir le nombre de jours jusqu'à l'expiration
  int get daysUntilExpiration {
    return expirationDate.difference(DateTime.now()).inDays;
  }

  // Formater la date d'expiration
  String get formattedExpirationDate {
    return Jiffy.parseFromDateTime(expirationDate).format(pattern: 'dd/MM/yyyy');
  }

  // Formater la date d'achat
  String get formattedPurchaseDate {
    return Jiffy.parseFromDateTime(purchaseDate).format(pattern: 'dd/MM/yyyy');
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, category: $category, expirationDate: $expirationDate}';
  }
}

enum ExpirationStatus {
  fresh,
  expiringSoon,
  expired,
}