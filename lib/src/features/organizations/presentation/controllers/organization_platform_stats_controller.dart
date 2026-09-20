import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/organization_repository.dart';
import '../../domain/organization_platform_stats.dart';

part 'organization_platform_stats_controller.g.dart';

/// Loads platform-wide organization metrics for Super Admin.
@riverpod
class OrganizationPlatformStatsController
    extends _$OrganizationPlatformStatsController {
  @override
  Future<OrganizationPlatformStatsResponse> build() async {
    final result =
        await ref.read(organizationRepositoryProvider).listPlatformStats();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(organizationRepositoryProvider).listPlatformStats();
      return result.fold(
        (failure) => throw failure,
        (data) => data,
      );
    });
  }
}
