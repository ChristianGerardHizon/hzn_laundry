import 'package:dart_mappable/dart_mappable.dart';

import '../../domain/app_config.dart';

part 'app_config_dto.mapper.dart';

/// DTO for converting version-manager JSON to [AppConfig] domain model.
@MappableClass()
class AppConfigDto with AppConfigDtoMappable {
  const AppConfigDto({
    required this.id,
    required this.major,
    required this.minor,
    required this.patch,
    required this.minimumMajor,
    required this.minimumMinor,
    required this.minimumPatch,
    required this.buildNumber,
  });

  final String id;
  final int major;
  final int minor;
  final int patch;
  final int minimumMajor;
  final int minimumMinor;
  final int minimumPatch;
  final int buildNumber;

  /// Creates a DTO from a JSON map (from the version-manager API).
  factory AppConfigDto.fromJson(Map<String, dynamic> json) {
    return AppConfigDto(
      id: json['id'] as String? ?? '',
      major: (json['major'] as num?)?.toInt() ?? 0,
      minor: (json['minor'] as num?)?.toInt() ?? 0,
      patch: (json['patch'] as num?)?.toInt() ?? 0,
      minimumMajor: (json['minimumMajor'] as num?)?.toInt() ?? 0,
      minimumMinor: (json['minimumMinor'] as num?)?.toInt() ?? 0,
      minimumPatch: (json['minimumPatch'] as num?)?.toInt() ?? 0,
      buildNumber: (json['buildNumber'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this DTO to an [AppConfig] domain entity.
  AppConfig toEntity() {
    return AppConfig(
      id: id,
      major: major,
      minor: minor,
      patch: patch,
      minimumMajor: minimumMajor,
      minimumMinor: minimumMinor,
      minimumPatch: minimumPatch,
      buildNumber: buildNumber,
    );
  }
}
