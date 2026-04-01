import 'package:dart_mappable/dart_mappable.dart';

part 'service_category.mapper.dart';

/// Service Category domain model.
///
/// Represents a category for grouping services (e.g., Wash, Dry, Iron).
@MappableClass()
class ServiceCategory with ServiceCategoryMappable {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Category name.
  final String name;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
