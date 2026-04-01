import 'package:dart_mappable/dart_mappable.dart';

import '../../quantity_units/domain/quantity_unit.dart';

part 'service.mapper.dart';

/// Service domain model.
///
/// Represents a laundry service (e.g., wash, dry, fold, iron).
@MappableClass()
class Service with ServiceMappable {
  const Service({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.branch,
    this.price = 0,
    this.isVariablePrice = false,
    this.estimatedDuration,
    this.weightBased = false,
    this.showPrompt = false,
    this.maxQuantity,
    this.allowExcess = false,
    this.quantityUnitId,
    this.quantityUnit,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Service name.
  final String name;

  /// Service description.
  final String? description;

  /// Category FK ID.
  final String? categoryId;

  /// Category name (expanded from FK).
  final String? categoryName;

  /// Branch FK ID.
  final String? branch;

  /// Service price.
  final num price;

  /// Whether this service has a variable price (entered at POS).
  final bool isVariablePrice;

  /// Estimated duration in minutes.
  final num? estimatedDuration;

  /// Whether pricing is weight-based.
  final bool weightBased;

  /// Whether to show a quantity prompt when adding this service to cart.
  final bool showPrompt;

  /// Maximum quantity allowed for this service (optional).
  final int? maxQuantity;

  /// Whether to allow quantities exceeding maxQuantity by splitting into multiple cart items.
  final bool allowExcess;

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

  /// Whether this service requires price entry at POS.
  bool get hasVariablePrice => isVariablePrice || price <= 0;

  /// Whether this service has a category.
  bool get hasCategory => categoryId != null && categoryId!.isNotEmpty;

  /// Formatted price display.
  String get priceDisplay =>
      hasVariablePrice ? 'Variable' : '₱${price.toStringAsFixed(2)}';

  /// Formatted duration display.
  String? get durationDisplay {
    if (estimatedDuration == null) return null;
    final hours = estimatedDuration! ~/ 60;
    final mins = estimatedDuration!.toInt() % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Formats a quantity with the appropriate unit label.
  ///
  /// Uses the assigned quantity unit if available, otherwise falls back to
  /// "kg" if weight-based or plain number.
  String formatQuantity(num quantity, {bool useShort = true}) {
    if (quantityUnit != null) {
      return quantityUnit!.format(quantity, useShort: useShort);
    }
    // Fallback for services without a quantity unit
    if (weightBased) {
      return '$quantity kg';
    }
    return '$quantity';
  }
}
