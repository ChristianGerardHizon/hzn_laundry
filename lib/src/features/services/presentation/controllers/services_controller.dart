import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/service_repository.dart';
import '../../domain/service.dart';

part 'services_controller.g.dart';

/// Controller for managing the list of services.
@Riverpod(keepAlive: true)
class ServicesController extends _$ServicesController {
  ServiceRepository get _repository => ref.read(serviceRepositoryProvider);

  @override
  Future<List<Service>> build() async {
    // Listen to branch changes and refresh
    ref.listen(currentBranchFilterProvider, (_, __) {
      refresh();
    });

    final branchFilter = ref.read(currentBranchFilterProvider);
    final result = await _repository.fetchAll(filter: branchFilter);

    return result.fold(
      (failure) => throw failure,
      (services) => services,
    );
  }

  /// Refreshes the service list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final branchFilter = ref.read(currentBranchFilterProvider);
    final result = await _repository.fetchAll(filter: branchFilter);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (services) => AsyncData(services),
    );
  }

  /// Creates a new service.
  Future<Service?> createService(Service service) async {
    final result = await _repository.create(service);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing service.
  Future<bool> updateService(Service service) async {
    final result = await _repository.update(service);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a service (soft delete).
  Future<bool> deleteService(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
