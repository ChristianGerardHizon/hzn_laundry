import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/incentive_tier.dart';

part 'incentive_tier_dto.mapper.dart';

/// Data Transfer Object for IncentiveTier from PocketBase.
@MappableClass()
class IncentiveTierDto with IncentiveTierDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String branch;
  final num minAmount;
  final num? maxAmount;
  final num incentiveAmount;
  final int sortOrder;
  final String? created;
  final String? updated;

  const IncentiveTierDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.branch,
    required this.minAmount,
    this.maxAmount,
    required this.incentiveAmount,
    this.sortOrder = 0,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory IncentiveTierDto.fromRecord(RecordModel record) {
    final maxAmt = record.get<num?>('maxAmount');
    return IncentiveTierDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      branch: record.getStringValue('branch'),
      minAmount: record.get<num>('minAmount'),
      maxAmount: (maxAmt != null && maxAmt > 0) ? maxAmt : null,
      incentiveAmount: record.get<num>('incentiveAmount'),
      sortOrder: record.get<int>('sortOrder'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain IncentiveTier entity.
  IncentiveTier toEntity() {
    return IncentiveTier(
      id: id,
      branch: branch,
      minAmount: minAmount,
      maxAmount: maxAmount,
      incentiveAmount: incentiveAmount,
      sortOrder: sortOrder,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
