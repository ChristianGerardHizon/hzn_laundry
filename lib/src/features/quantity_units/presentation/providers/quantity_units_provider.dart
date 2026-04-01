import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/quantity_unit_repository.dart';
import '../../domain/quantity_unit.dart';

part 'quantity_units_provider.g.dart';

/// Provides all quantity units.
@riverpod
Future<List<QuantityUnit>> quantityUnits(Ref ref) async {
  final repository = ref.watch(quantityUnitRepositoryProvider);
  final result = await repository.fetchAll();
  return result.fold(
    (failure) => throw failure,
    (units) => units,
  );
}
