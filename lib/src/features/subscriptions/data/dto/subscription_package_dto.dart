import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../entitlements/domain/feature_key.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/subscription_package.dart';

part 'subscription_package_dto.mapper.dart';

@MappableClass()
class SubscriptionPackageDto with SubscriptionPackageDtoMappable {
  const SubscriptionPackageDto({
    required this.id,
    required this.name,
    this.description = '',
    this.price = 0,
    this.intervalCount = 1,
    this.intervalUnit = 'month',
    this.isPremade = true,
    this.organizationId,
    this.isActive = true,
    this.isDeleted = false,
    this.features = const [],
    this.maxBranches,
    this.maxEmployees,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final int intervalCount;
  final String intervalUnit;
  final bool isPremade;
  final String? organizationId;
  final bool isActive;
  final bool isDeleted;
  final List<String> features;
  final int? maxBranches;
  final int? maxEmployees;

  factory SubscriptionPackageDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _asNum(json['price']),
      intervalCount: _asInt(json['intervalCount'], fallback: 1),
      intervalUnit: json['intervalUnit'] as String? ?? 'month',
      isPremade: json['isPremade'] as bool? ?? true,
      organizationId: _relationId(json['organizationId']),
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      features: _asFeatureKeys(json['features']),
      maxBranches: _asLimit(json['maxBranches']),
      maxEmployees: _asLimit(json['maxEmployees']),
    );
  }

  factory SubscriptionPackageDto.fromRecord(RecordModel record) {
    return SubscriptionPackageDto.fromJson(record.toJson());
  }

  SubscriptionPackage toEntity() {
    return SubscriptionPackage(
      id: id,
      name: name,
      description: description,
      price: price,
      intervalCount: intervalCount,
      intervalUnit: BillingIntervalUnit.fromString(intervalUnit),
      isPremade: isPremade,
      organizationId: organizationId != null && organizationId!.isNotEmpty
          ? organizationId
          : null,
      isActive: isActive,
      isDeleted: isDeleted,
      features: features,
      maxBranches: maxBranches,
      maxEmployees: maxEmployees,
    );
  }
}

/// A limit of 0 / missing means unlimited.
int? _asLimit(dynamic value) {
  final v = _asInt(value);
  return v > 0 ? v : null;
}

/// Missing/legacy `features` means the package predates entitlements and
/// includes everything.
List<String> _asFeatureKeys(dynamic value) {
  if (value is List) return value.whereType<String>().toList();
  return [
    for (final f in FeatureKey.values)
      if (!f.defaultOff) f.key,
  ];
}

String? _relationId(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) return value['id'] as String?;
  return value.toString();
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

num _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}
