import 'package:dart_mappable/dart_mappable.dart';

part 'organization_platform_stats.mapper.dart';

/// Platform-wide totals for the Super Admin dashboard.
@MappableClass()
class OrganizationPlatformSummary with OrganizationPlatformSummaryMappable {
  const OrganizationPlatformSummary({
    required this.organizationCount,
    required this.orderCount,
    required this.customerCount,
    required this.revenue,
  });

  final int organizationCount;
  final int orderCount;
  final int customerCount;
  final num revenue;
}

/// Per-organization metrics for the Super Admin list.
@MappableClass()
class OrganizationPlatformStats with OrganizationPlatformStatsMappable {
  const OrganizationPlatformStats({
    required this.id,
    required this.name,
    required this.slug,
    this.onboardingCompletedAt,
    required this.branchCount,
    required this.memberCount,
    required this.orderCount,
    required this.customerCount,
    required this.revenue,
    this.subscriptionStatus,
    this.periodEnd,
    this.graceEndsAt,
    this.pendingPaymentCount = 0,
    this.packageName,
  });

  final String id;
  final String name;
  final String slug;
  final DateTime? onboardingCompletedAt;
  final int branchCount;
  final int memberCount;
  final int orderCount;
  final int customerCount;
  final num revenue;
  final String? subscriptionStatus;
  final DateTime? periodEnd;
  final DateTime? graceEndsAt;
  final int pendingPaymentCount;
  final String? packageName;

  bool get isOnboarded => onboardingCompletedAt != null;
}

/// Response from `GET /api/super-admin/organization-stats`.
@MappableClass()
class OrganizationPlatformStatsResponse
    with OrganizationPlatformStatsResponseMappable {
  const OrganizationPlatformStatsResponse({
    required this.summary,
    required this.organizations,
  });

  final OrganizationPlatformSummary summary;
  final List<OrganizationPlatformStats> organizations;
}
