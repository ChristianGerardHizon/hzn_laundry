import 'package:dart_mappable/dart_mappable.dart';

part 'customer_address.mapper.dart';

/// A saved delivery address for a customer. A customer can have many; exactly
/// one non-deleted address is the default.
@MappableClass()
class CustomerAddress with CustomerAddressMappable {
  const CustomerAddress({
    required this.id,
    required this.customerId,
    required this.address,
    this.label,
    this.notes,
    this.distanceKm,
    this.deliveryRateId,
    this.isDefault = false,
  });

  final String id;
  final String customerId;

  /// Optional short name, e.g. "Home" or "Office".
  final String? label;
  final String address;
  final String? notes;

  /// Distance to this address in km (prefills new orders).
  final num? distanceKm;

  /// Optional rate this address always uses (falls back to the branch default).
  final String? deliveryRateId;
  final bool isDefault;

  /// "Home - 12 Main St", or just the address when there is no label.
  String get displayName => (label != null && label!.trim().isNotEmpty)
      ? '${label!} - $address'
      : address;
}
