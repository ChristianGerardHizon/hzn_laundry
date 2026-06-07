import 'package:dart_mappable/dart_mappable.dart';

part 'machine_size.mapper.dart';

/// Machine size classification.
///
/// Drives weight-based load rules: a small and a large machine of the same
/// type can have different weight tiers.
@MappableEnum()
enum MachineSize {
  small,
  large;

  String get displayName => switch (this) {
        MachineSize.small => 'Small',
        MachineSize.large => 'Large',
      };

  /// Parses a stored name into a [MachineSize], returning null for null,
  /// empty, or unrecognized values (treated as "unspecified").
  static MachineSize? fromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final value in MachineSize.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
