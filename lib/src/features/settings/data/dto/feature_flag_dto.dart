import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/feature_flag.dart';

part 'feature_flag_dto.mapper.dart';

@MappableClass()
class FeatureFlagDto with FeatureFlagDtoMappable {
  const FeatureFlagDto({
    required this.id,
    required this.key,
    required this.enabled,
    this.description,
    this.organization,
  });

  final String id;
  final String key;
  final bool enabled;
  final String? description;
  final String? organization;

  factory FeatureFlagDto.fromJson(Map<String, dynamic> json) {
    return FeatureFlagDto(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      description: json['description'] as String?,
      organization: json['organization'] as String?,
    );
  }

  factory FeatureFlagDto.fromRecord(RecordModel record) {
    return FeatureFlagDto.fromJson(record.toJson());
  }

  FeatureFlag toEntity() {
    return FeatureFlag(
      id: id,
      key: key,
      enabled: enabled,
      description: description,
      organizationId: organization,
    );
  }
}
