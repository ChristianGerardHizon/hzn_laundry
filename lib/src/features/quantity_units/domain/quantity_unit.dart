import 'package:dart_mappable/dart_mappable.dart';

part 'quantity_unit.mapper.dart';

/// Quantity unit domain model.
///
/// Represents a unit of measurement for quantities (e.g., pieces, kilograms).
@MappableClass()
class QuantityUnit with QuantityUnitMappable {
  const QuantityUnit({
    required this.id,
    required this.name,
    required this.shortSingular,
    required this.shortPlural,
    required this.longSingular,
    required this.longPlural,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase collection name.
  static const String collectionName = 'quantityUnits';

  /// PocketBase record ID.
  final String id;

  /// Full name of the unit (e.g., "kilograms", "pieces").
  final String name;

  /// Short singular form (e.g., "kg", "pc").
  final String shortSingular;

  /// Short plural form (e.g., "kg", "pcs").
  final String shortPlural;

  /// Long singular form (e.g., "kilogram", "piece").
  final String longSingular;

  /// Long plural form (e.g., "kilograms", "pieces").
  final String longPlural;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Formats a quantity with the appropriate unit label.
  ///
  /// Automatically uses singular/plural form based on quantity.
  /// [useShort] determines whether to use short (kg) or long (kilogram) form.
  String format(num quantity, {bool useShort = true}) {
    final isPlural = quantity != 1;
    if (useShort) {
      return '$quantity ${isPlural ? shortPlural : shortSingular}';
    }
    return '$quantity ${isPlural ? longPlural : longSingular}';
  }

  /// Display name with short form in parentheses.
  String get displayName => '$name ($shortPlural)';
}
