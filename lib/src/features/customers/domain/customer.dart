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
    this.branchId,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Customer name.
  final String name;

  /// Branch ID where this customer was created.
  final String? branchId;

  /// Customer phone number (optional).
  final String? phone;

  /// Customer email (optional). Used for sending order history link.
  final String? email;

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
