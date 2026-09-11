import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sale_consumable_usage_repository.dart';
import '../../../pos/domain/sale_consumable_usage.dart';

part 'sale_consumable_usages_provider.g.dart';

@riverpod
Future<List<SaleConsumableUsage>> saleConsumableUsages(
  Ref ref,
  String saleId,
) async {
  final result = await ref
      .read(saleConsumableUsageRepositoryProvider)
      .fetchForSale(saleId);
  return result.fold((failure) => throw failure, (usages) => usages);
}
