import 'package:dart_mappable/dart_mappable.dart';

part 'app_config.mapper.dart';

/// Version config from the external version-manager service.
///
/// Represents a record in the `versions` collection.
@MappableClass()
class AppConfig with AppConfigMappable {
  const AppConfig({
    required this.id,
    required this.major,
    required this.minor,
    required this.patch,
    required this.minimumMajor,
    required this.minimumMinor,
    required this.minimumPatch,
    required this.buildNumber,
  });

  /// PocketBase record ID.
  final String id;

  /// Latest version components.
  final int major;
  final int minor;
  final int patch;

  /// Minimum supported version components.
  final int minimumMajor;
  final int minimumMinor;
  final int minimumPatch;

  /// Build number of the latest version.
  final int buildNumber;

  /// Latest version as a string (e.g., "1.3.0").
  String get latestVersion => '$major.$minor.$patch';

  /// Minimum supported version as a string (e.g., "1.0.0").
  String get minimumVersion => '$minimumMajor.$minimumMinor.$minimumPatch';
}
