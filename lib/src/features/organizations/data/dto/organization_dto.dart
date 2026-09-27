import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/organization.dart';

part 'organization_dto.mapper.dart';

@MappableClass()
class OrganizationDto with OrganizationDtoMappable {
  const OrganizationDto({
    required this.id,
    required this.name,
    required this.slug,
    this.contactNumber,
    this.address,
    this.logo,
    this.onboardingCompletedAt,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  final String id;
  final String name;
  final String slug;
  final String? contactNumber;
  final String? address;

  /// PocketBase file filename (not a full URL).
  final String? logo;
  final String? onboardingCompletedAt;
  final bool isDeleted;
  final String? created;
  final String? updated;

  factory OrganizationDto.fromJson(Map<String, dynamic> json) {
    return OrganizationDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      contactNumber: json['contactNumber'] as String?,
      address: json['address'] as String?,
      logo: _parseLogoFilename(json['logo']),
      onboardingCompletedAt: json['onboardingCompletedAt'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  factory OrganizationDto.fromRecord(RecordModel record) {
    return OrganizationDto.fromJson(record.toJson());
  }

  Organization toEntity({String? baseUrl}) {
    return Organization(
      id: id,
      name: name,
      slug: slug,
      contactNumber: contactNumber,
      address: address,
      logoUrl: _buildLogoUrl(baseUrl),
      onboardingCompletedAt: parseToLocal(onboardingCompletedAt),
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  String? _buildLogoUrl(String? baseUrl) {
    if (logo == null || logo!.isEmpty || baseUrl == null || baseUrl.isEmpty) {
      return null;
    }
    final collection = PocketBaseCollections.organizations;
    return '$baseUrl/api/files/$collection/$id/$logo';
  }

  static String? _parseLogoFilename(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }
}
