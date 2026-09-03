import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/organization.dart';

part 'organization_dto.mapper.dart';

@MappableClass()
class OrganizationDto with OrganizationDtoMappable {
  const OrganizationDto({
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
  final String? onboardingCompletedAt;
  final bool isDeleted;
  final String? created;
  final String? updated;

  factory OrganizationDto.fromJson(Map<String, dynamic> json) {
    return OrganizationDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      contactNumber: json['contactNumber'] as String?,
      address: json['address'] as String?,
      onboardingCompletedAt: json['onboardingCompletedAt'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  factory OrganizationDto.fromRecord(RecordModel record) {
    return OrganizationDto.fromJson(record.toJson());
  }

  Organization toEntity() {
    return Organization(
      id: id,
      name: name,
      contactNumber: contactNumber,
      address: address,
      onboardingCompletedAt: parseToLocal(onboardingCompletedAt),
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
