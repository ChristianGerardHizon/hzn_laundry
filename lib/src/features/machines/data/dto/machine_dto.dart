import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/machine.dart';
import '../../domain/machine_type.dart';

part 'machine_dto.mapper.dart';

/// Data Transfer Object for Machine from PocketBase.
@MappableClass()
class MachineDto with MachineDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String type;
  final String? branch;
  final bool isAvailable;
  final bool strictSingleUse;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const MachineDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.type,
    this.branch,
    this.isAvailable = true,
    this.strictSingleUse = false,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MachineDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return MachineDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      branch: json['branch'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      strictSingleUse: json['strictSingleUse'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain Machine entity.
  Machine toEntity() {
    return Machine(
      id: id,
      name: name,
      type: MachineType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => MachineType.other,
      ),
      branchId: branch,
      isAvailable: isAvailable,
      strictSingleUse: strictSingleUse,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
