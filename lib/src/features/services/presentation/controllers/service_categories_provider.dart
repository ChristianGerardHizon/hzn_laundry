import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/service_category_repository.dart';
import '../../domain/service_category.dart';

part 'service_categories_provider.g.dart';

/// Provider for all service categories.
@riverpod
Future<List<ServiceCategory>> serviceCategories(Ref ref) async {
  final repository = ref.read(serviceCategoryRepositoryProvider);
  final result = await repository.fetchAll();

  return result.fold(
    (failure) => [],
    (categories) => categories,
  );
}
