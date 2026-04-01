import 'package:dart_mappable/dart_mappable.dart';

import '../../quantity_units/domain/quantity_unit.dart';
import 'product_status.dart';

part 'product.mapper.dart';

/// Product domain model.
///
/// Represents a product/inventory item in the system.
@MappableClass()
class Product with ProductMappable {
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.image,
    this.branch,
    this.stockThreshold,
    this.price = 0,
    this.forSale = true,
    this.trackStock = false,
    this.requireStock = false,
    this.quantity,
    this.expiration,
    this.trackByLot = false,
    this.quantityUnitId,
    this.quantityUnit,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Product name.
  final String name;

  /// Product description.
  final String? description;

  /// Category FK ID.
  final String? categoryId;

  /// Category name (expanded from FK).
  final String? categoryName;

  /// Product image URL (full path).
  final String? image;

  /// Branch FK ID.
  final String? branch;

  /// Low stock warning threshold.
  final num? stockThreshold;

  /// Product price.
  final num price;

  /// Whether product is for sale.
  final bool forSale;

  /// Whether stock tracking is enabled for this product.
  final bool trackStock;

  /// Whether stock is required to add to cart.
  /// If true and product is out of stock, it cannot be added to cart.
  final bool requireStock;

  /// Current quantity (for non-lot tracking).
  final num? quantity;

  /// Expiration date (for non-lot tracking).
  final DateTime? expiration;

  /// Whether to track inventory by lot numbers.
  final bool trackByLot;

  /// Quantity unit FK ID.
  final String? quantityUnitId;

  /// Quantity unit (expanded from FK).
  final QuantityUnit? quantityUnit;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns true if product has an image.
  bool get hasImage => image != null && image!.isNotEmpty;

  /// Returns true if product has a category.
  bool get hasCategory => categoryId != null && categoryId!.isNotEmpty;

  /// Returns true if stock is low based on threshold.
  /// Returns false if out of stock (qty <= 0) since that's a different status.
  bool get isLowStock {
    if (!trackStock) return false;
    if (stockThreshold == null) return false;
    // For lot-tracked products, treat null quantity as 0
    final qty = trackByLot ? (quantity ?? 0) : quantity;
    if (qty == null) return false;
    // Out of stock is not the same as low stock
    if (qty <= 0) return false;
    return qty <= stockThreshold!;
  }

  /// Returns true if product is expired.
  bool get isExpired {
    if (expiration == null) return false;
    return expiration!.isBefore(DateTime.now());
  }

  /// Default threshold for near expiration warning (30 days).
  static const nearExpirationDays = 30;

  /// Returns true if product is near expiration (within 30 days).
  bool get isNearExpiration {
    if (expiration == null) return false;
    if (isExpired) return false; // Already expired, not "near"
    final daysUntilExpiration = expiration!.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= nearExpirationDays;
  }

  /// Returns the number of days until expiration (negative if expired).
  int? get daysUntilExpiration {
    if (expiration == null) return null;
    return expiration!.difference(DateTime.now()).inDays;
  }

  /// Returns true if product is out of stock.
  bool get isOutOfStock {
    if (!trackStock) return false;
    // For lot-tracked products, treat null quantity as 0
    if (trackByLot) {
      return (quantity ?? 0) <= 0;
    }
    return quantity != null && quantity! <= 0;
  }

  /// Calculates the stock status.
  ProductStatus get stockStatus {
    if (!trackStock) return ProductStatus.noThreshold;

    // For lot-tracked products, treat null quantity as 0 (out of stock)
    // since quantity is synced from lots
    if (trackByLot) {
      final qty = quantity ?? 0;
      if (qty <= 0) return ProductStatus.outOfStock;
      if (stockThreshold != null && qty <= stockThreshold!) {
        return ProductStatus.lowStock;
      }
      return ProductStatus.inStock;
    }

    // For non-lot products, null quantity means no threshold set
    if (quantity == null) return ProductStatus.noThreshold;
    if (quantity! <= 0) return ProductStatus.outOfStock;
    if (stockThreshold != null && quantity! <= stockThreshold!) {
      return ProductStatus.lowStock;
    }
    return ProductStatus.inStock;
  }

  /// Whether this product has a variable price (price must be entered at POS).
  bool get isVariablePrice => price <= 0;

  /// Formatted price display.
  String get priceDisplay =>
      isVariablePrice ? 'Variable' : '₱${price.toStringAsFixed(2)}';

  /// Formatted quantity display.
  String get quantityDisplay {
    if (quantity == null) return 'N/A';
    return quantity!.toStringAsFixed(0);
  }

  /// Formats a quantity with the appropriate unit label.
  ///
  /// Uses the assigned quantity unit if available, otherwise falls back to "pcs".
  String formatQuantity(num qty, {bool useShort = true}) {
    if (quantityUnit != null) {
      return quantityUnit!.format(qty, useShort: useShort);
    }
    // Fallback for products without a quantity unit
    final isPlural = qty != 1;
    return '${qty.toInt()} ${isPlural ? "pcs" : "pc"}';
  }
}
