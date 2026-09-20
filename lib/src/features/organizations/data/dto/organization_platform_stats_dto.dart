import 'package:dart_mappable/dart_mappable.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/organization_platform_stats.dart';

part 'organization_platform_stats_dto.mapper.dart';

@MappableClass()
class OrganizationPlatformSummaryDto
    with OrganizationPlatformSummaryDtoMappable {
  const OrganizationPlatformSummaryDto({
    this.organizationCount = 0,
    this.orderCount = 0,
    this.customerCount = 0,
    this.revenue = 0,
  });

  final int organizationCount;
  final int orderCount;
  final int customerCount;
  final num revenue;

  factory OrganizationPlatformSummaryDto.fromJson(Map<String, dynamic> json) {
    return OrganizationPlatformSummaryDto(
      organizationCount: _asInt(json['organizationCount']),
      orderCount: _asInt(json['orderCount']),
      customerCount: _asInt(json['customerCount']),
      revenue: _asNum(json['revenue']),
    );
  }

  OrganizationPlatformSummary toEntity() {
    return OrganizationPlatformSummary(
      organizationCount: organizationCount,
      orderCount: orderCount,
      customerCount: customerCount,
      revenue: revenue,
    );
  }
}

@MappableClass()
class OrganizationPlatformStatsDto with OrganizationPlatformStatsDtoMappable {
  const OrganizationPlatformStatsDto({
    required this.id,
    required this.name,
    this.slug = '',
    this.onboardingCompletedAt,
    this.branchCount = 0,
    this.memberCount = 0,
    this.orderCount = 0,
    this.customerCount = 0,
    this.revenue = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? onboardingCompletedAt;
  final int branchCount;
  final int memberCount;
  final int orderCount;
  final int customerCount;
  final num revenue;

  factory OrganizationPlatformStatsDto.fromJson(Map<String, dynamic> json) {
    return OrganizationPlatformStatsDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      onboardingCompletedAt: json['onboardingCompletedAt'] as String?,
      branchCount: _asInt(json['branchCount']),
      memberCount: _asInt(json['memberCount']),
      orderCount: _asInt(json['orderCount']),
      customerCount: _asInt(json['customerCount']),
      revenue: _asNum(json['revenue']),
    );
  }

  OrganizationPlatformStats toEntity() {
    return OrganizationPlatformStats(
      id: id,
      name: name,
      slug: slug,
      onboardingCompletedAt: parseToLocal(onboardingCompletedAt),
      branchCount: branchCount,
      memberCount: memberCount,
      orderCount: orderCount,
      customerCount: customerCount,
      revenue: revenue,
    );
  }
}

@MappableClass()
class OrganizationPlatformStatsResponseDto
    with OrganizationPlatformStatsResponseDtoMappable {
  const OrganizationPlatformStatsResponseDto({
    required this.summary,
    required this.organizations,
  });

  final OrganizationPlatformSummaryDto summary;
  final List<OrganizationPlatformStatsDto> organizations;

  factory OrganizationPlatformStatsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final summaryJson = json['summary'];
    final orgsJson = json['organizations'];
    return OrganizationPlatformStatsResponseDto(
      summary: summaryJson is Map<String, dynamic>
          ? OrganizationPlatformSummaryDto.fromJson(summaryJson)
          : const OrganizationPlatformSummaryDto(),
      organizations: orgsJson is List
          ? orgsJson
              .whereType<Map<String, dynamic>>()
              .map(OrganizationPlatformStatsDto.fromJson)
              .toList()
          : const [],
    );
  }

  OrganizationPlatformStatsResponse toEntity() {
    return OrganizationPlatformStatsResponse(
      summary: summary.toEntity(),
      organizations: organizations.map((o) => o.toEntity()).toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

num _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}
