import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/organization_subscription.dart';
import '../../domain/subscription_status.dart';

part 'organization_subscription_dto.mapper.dart';

@MappableClass()
class OrganizationSubscriptionDto with OrganizationSubscriptionDtoMappable {
  const OrganizationSubscriptionDto({
    required this.id,
    required this.organization,
    required this.package,
    required this.packageName,
    this.price = 0,
    this.intervalCount = 1,
    this.intervalUnit = 'month',
    this.status = 'active',
    this.periodStart,
    this.periodEnd,
    this.graceEndsAt,
    this.nextReminderAt,
    this.manualUnlockUntil,
    this.lastReminderSentAt,
    this.isDeleted = false,
  });

  final String id;
  final String organization;
  final String package;
  final String packageName;
  final num price;
  final int intervalCount;
  final String intervalUnit;
  final String status;
  final String? periodStart;
  final String? periodEnd;
  final String? graceEndsAt;
  final String? nextReminderAt;
  final String? manualUnlockUntil;
  final String? lastReminderSentAt;
  final bool isDeleted;

  factory OrganizationSubscriptionDto.fromJson(Map<String, dynamic> json) {
    return OrganizationSubscriptionDto(
      id: json['id'] as String? ?? '',
      organization: _relationId(json['organization']) ?? '',
      package: _relationId(json['package']) ?? '',
      packageName: json['packageName'] as String? ?? '',
      price: _asNum(json['price']),
      intervalCount: _asInt(json['intervalCount'], fallback: 1),
      intervalUnit: json['intervalUnit'] as String? ?? 'month',
      status: json['status'] as String? ?? 'active',
      periodStart: json['periodStart'] as String?,
      periodEnd: json['periodEnd'] as String?,
      graceEndsAt: json['graceEndsAt'] as String?,
      nextReminderAt: json['nextReminderAt'] as String?,
      manualUnlockUntil: json['manualUnlockUntil'] as String?,
      lastReminderSentAt: json['lastReminderSentAt'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  factory OrganizationSubscriptionDto.fromRecord(RecordModel record) {
    return OrganizationSubscriptionDto.fromJson(record.toJson());
  }

  OrganizationSubscription toEntity() {
    final now = DateTime.now();
    return OrganizationSubscription(
      id: id,
      organizationId: organization,
      packageId: package,
      packageName: packageName,
      price: price,
      intervalCount: intervalCount,
      intervalUnit: BillingIntervalUnit.fromString(intervalUnit),
      status: SubscriptionStatus.fromString(status),
      periodStart: parseToLocalOrDefault(periodStart, now),
      periodEnd: parseToLocalOrDefault(periodEnd, now),
      graceEndsAt: parseToLocal(graceEndsAt),
      nextReminderAt: parseToLocal(nextReminderAt),
      manualUnlockUntil: parseToLocal(manualUnlockUntil),
      lastReminderSentAt: parseToLocal(lastReminderSentAt),
      isDeleted: isDeleted,
    );
  }
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
