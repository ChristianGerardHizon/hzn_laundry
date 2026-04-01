import 'package:dart_mappable/dart_mappable.dart';

part 'customer.mapper.dart';

/// Customer domain model.
///
/// Represents a customer of the laundry business.
@MappableClass()
class Customer with CustomerMappable {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Customer name.
  final String name;

  /// Customer phone number (optional).
  final String? phone;

  /// Customer address (optional).
  final String? address;

  /// Notes about the customer (optional).
  final String? notes;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Display string for list tiles.
  String get subtitle => phone ?? '';
}
