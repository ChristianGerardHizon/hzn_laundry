import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/service_consumable_recipe.dart';
import '../dto/service_consumable_recipe_dto.dart';

part 'service_consumable_recipe_repository.g.dart';

abstract class ServiceConsumableRecipeRepository {
  FutureEither<List<ServiceConsumableRecipe>> fetchForService(String serviceId);
  FutureEither<ServiceConsumableRecipe> create(ServiceConsumableRecipe recipe);
  FutureEither<ServiceConsumableRecipe> update(ServiceConsumableRecipe recipe);
  FutureEither<void> delete(String id);
}

@Riverpod(keepAlive: true)
ServiceConsumableRecipeRepository serviceConsumableRecipeRepository(Ref ref) {
  return ServiceConsumableRecipeRepositoryImpl(ref.watch(pocketbaseProvider));
}

class ServiceConsumableRecipeRepositoryImpl
    implements ServiceConsumableRecipeRepository {
  ServiceConsumableRecipeRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.serviceConsumableRecipes);

  ServiceConsumableRecipe _toEntity(RecordModel record) {
    final productExpanded = record.get<RecordModel?>('expand.product');
    return ServiceConsumableRecipeDto.fromRecord(record)
        .toEntity(productExpanded: productExpanded);
  }

  @override
  FutureEither<List<ServiceConsumableRecipe>> fetchForService(
    String serviceId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: 'service = "$serviceId"',
          sort: 'created',
          expand: 'product,product.quantityUnit',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ServiceConsumableRecipe> create(
    ServiceConsumableRecipe recipe,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.create(
          body: {
            'service': recipe.serviceId,
            'product': recipe.productId,
            'defaultQuantity': recipe.defaultQuantity,
            'prefill': recipe.prefill,
          },
          expand: 'product,product.quantityUnit',
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ServiceConsumableRecipe> update(
    ServiceConsumableRecipe recipe,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(
          recipe.id,
          body: {
            'defaultQuantity': recipe.defaultQuantity,
            'prefill': recipe.prefill,
            'product': recipe.productId,
          },
          expand: 'product,product.quantityUnit',
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.delete(id);
      },
      Failure.handle,
    ).run();
  }
}
