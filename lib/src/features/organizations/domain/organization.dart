import 'package:dart_mappable/dart_mappable.dart';

part 'organization.mapper.dart';

/// Multi-tenant organization (tenant boundary above branches).
@MappableClass()
class Organization with OrganizationMappable {
  const Organization({
    required this.id,
    required this.name,
    this.contactNumber,
    this.address,
    this.onboardingCompletedAt,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  final String id;
  final String name;
  final String? contactNumber;
  final String? address;
  final DateTime? onboardingCompletedAt;
  final bool isDeleted;
  final DateTime? created;
  final DateTime? updated;

  bool get isOnboarded => onboardingCompletedAt != null;
}
