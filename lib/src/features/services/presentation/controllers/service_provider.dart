import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/service_repository.dart';
import '../../domain/service.dart';

part 'service_provider.g.dart';

/// Provider for a single service by ID.
@riverpod
Future<Service?> service(Ref ref, String id) async {
  final repository = ref.read(serviceRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (service) => service,
  );
}
