import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/load_rule.dart';

part 'load_rule_dto.mapper.dart';

/// Data Transfer Object for LoadRule from PocketBase.
@MappableClass()
class LoadRuleDto with LoadRuleDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String machine;
  final num? minWeight;
  final num? maxWeight;
  final num loadCount;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const LoadRuleDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.machine,
    required this.loadCount,
    this.minWeight,
    this.maxWeight,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory LoadRuleDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return LoadRuleDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      machine: json['machine'] as String? ?? '',
      minWeight: json['minWeight'] as num?,
      maxWeight: json['maxWeight'] as num?,
      loadCount: (json['loadCount'] as num?) ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain LoadRule entity.
  LoadRule toEntity() {
    return LoadRule(
      id: id,
      machineId: machine,
      loadCount: loadCount.toInt(),
      minWeight: minWeight?.toDouble(),
      maxWeight: maxWeight?.toDouble(),
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  /// Builds a PocketBase create/update body from a domain [LoadRule].
  ///
  /// A null weight bound is sent as `null` so PocketBase clears the field,
  /// representing "no lower bound" / "and up".
  static Map<String, dynamic> toBody(LoadRule rule) {
    return <String, dynamic>{
      'machine': rule.machineId,
      'minWeight': rule.minWeight,
      'maxWeight': rule.maxWeight,
      'loadCount': rule.loadCount,
      'isDeleted': rule.isDeleted,
    };
  }
}
