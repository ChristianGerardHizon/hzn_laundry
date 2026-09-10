import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/service_consumable_recipe_repository.dart';
import '../../domain/service_consumable_recipe.dart';

part 'service_consumable_recipes_provider.g.dart';

@riverpod
Future<List<ServiceConsumableRecipe>> serviceConsumableRecipes(
  Ref ref,
  String serviceId,
) async {
  final result = await ref
      .read(serviceConsumableRecipeRepositoryProvider)
      .fetchForService(serviceId);
  return result.fold((failure) => throw failure, (recipes) => recipes);
}
