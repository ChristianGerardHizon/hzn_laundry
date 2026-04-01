import 'package:dart_mappable/dart_mappable.dart';

part 'machine_type.mapper.dart';

/// Machine type enum.
@MappableEnum()
enum MachineType {
  washer,
  dryer,
  other;

  String get displayName => switch (this) {
        MachineType.washer => 'Washer',
        MachineType.dryer => 'Dryer',
        MachineType.other => 'Other',
      };
}
