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
  });

  final String id;
  final String key;
  final bool enabled;
  final String? description;

  factory FeatureFlagDto.fromRecord(RecordModel record) {
    final json = record.toJson();
    return FeatureFlagDto(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  FeatureFlag toEntity() {
    return FeatureFlag(
      id: id,
      key: key,
      enabled: enabled,
      description: description,
    );
  }
}
