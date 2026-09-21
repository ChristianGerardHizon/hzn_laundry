import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/subscription_package.dart';

part 'packages_controller.g.dart';

/// Super Admin list of subscription packages.
@riverpod
class PackagesController extends _$PackagesController {
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  Future<List<SubscriptionPackage>> build({bool premadeOnly = false}) async {
    final result = await _repository.listPackages(premadeOnly: premadeOnly);
    return result.fold(
      (failure) => throw failure,
      (packages) => packages,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await _repository.listPackages(premadeOnly: premadeOnly);
      return result.fold(
        (failure) => throw failure,
        (packages) => packages,
      );
    });
  }

  Future<SubscriptionPackage?> createPackage({
    required String name,
    String description = '',
    required num price,
    required int intervalCount,
    required BillingIntervalUnit intervalUnit,
    required bool isPremade,
    String? organizationId,
  }) async {
    final result = await _repository.createPackage(
      name: name,
      description: description,
      price: price,
      intervalCount: intervalCount,
      intervalUnit: intervalUnit,
      isPremade: isPremade,
      organizationId: organizationId,
    );
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  Future<bool> updatePackage(
    String id, {
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    bool? isPremade,
    bool? isActive,
    String? organizationId,
  }) async {
    final result = await _repository.updatePackage(
      id,
      name: name,
      description: description,
      price: price,
      intervalCount: intervalCount,
      intervalUnit: intervalUnit,
      isPremade: isPremade,
      isActive: isActive,
      organizationId: organizationId,
    );
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  Future<bool> softDeletePackage(String id) async {
    final result = await _repository.softDeletePackage(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
