import 'package:dart_mappable/dart_mappable.dart';

import 'billing_interval_unit.dart';

part 'subscription_package.mapper.dart';

/// Premade or custom subscription package (₱ pricing).
@MappableClass()
class SubscriptionPackage with SubscriptionPackageMappable {
  const SubscriptionPackage({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.intervalCount,
    required this.intervalUnit,
    this.isPremade = true,
    this.organizationId,
    this.isActive = true,
    this.isDeleted = false,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final int intervalCount;
  final BillingIntervalUnit intervalUnit;
  final bool isPremade;
  final String? organizationId;
  final bool isActive;
  final bool isDeleted;
}
