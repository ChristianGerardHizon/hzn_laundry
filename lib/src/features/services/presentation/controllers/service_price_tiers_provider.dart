import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../data/dto/service_price_tier_dto.dart';
import '../../domain/service_price_tier.dart';

part 'service_price_tiers_provider.g.dart';

/// Fetches all price tiers for a given service, sorted by minQuantity.
@riverpod
Future<List<ServicePriceTier>> servicePriceTiers(
  Ref ref,
  String serviceId,
) async {
  final pb = ref.watch(pocketbaseProvider);
  final records = await pb
      .collection(PocketBaseCollections.servicePriceTiers)
      .getFullList(
        filter: 'service = "$serviceId"',
        sort: 'minQuantity',
      );

  return records
      .map((r) => ServicePriceTierDto.fromRecord(r).toEntity())
      .toList();
}
