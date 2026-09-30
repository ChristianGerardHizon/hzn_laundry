import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/entitlement_limit.dart';
import '../../domain/feature_key.dart';
import '../../domain/organization_entitlements.dart';
import '../dto/organization_entitlements_dto.dart';

part 'entitlement_repository.g.dart';

abstract class EntitlementRepository {
  /// Resolved entitlements (package base + Super Admin overrides).
  FutureEither<OrganizationEntitlements> fetch(String organizationId);

  /// Super Admin only. [enabled] `null` clears the override (follow plan).
  FutureEither<OrganizationEntitlements> setOverride(
    String organizationId,
    FeatureKey feature, {
    required bool? enabled,
    String? note,
  });

  /// Super Admin only. [value] `null` clears the override (follow plan);
  /// `0` forces unlimited.
  FutureEither<OrganizationEntitlements> setLimitOverride(
    String organizationId,
    LimitKey limit, {
    required int? value,
    String? note,
  });
}

@Riverpod(keepAlive: true)
EntitlementRepository entitlementRepository(Ref ref) {
  return EntitlementRepositoryImpl(ref.watch(pocketbaseProvider));
}

class EntitlementRepositoryImpl implements EntitlementRepository {
  EntitlementRepositoryImpl(this._pb);

  final PocketBase _pb;

  OrganizationEntitlements _parse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const DataFailure(
        'Invalid entitlements response',
        null,
        'invalid_entitlements_response',
      );
    }
    return OrganizationEntitlementsDto.fromJson(response);
  }

  @override
  FutureEither<OrganizationEntitlements> fetch(String organizationId) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }
        final response = await _pb.send(
          '/api/organizations/$organizationId/entitlements',
          method: 'GET',
        );
        return _parse(response);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationEntitlements> setOverride(
    String organizationId,
    FeatureKey feature, {
    required bool? enabled,
    String? note,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }
        final response = await _pb.send(
          '/api/super-admin/organizations/$organizationId'
          '/feature-overrides/${feature.key}',
          method: 'PUT',
          body: {
            'enabled': enabled,
            if (note != null) 'note': note,
          },
        );
        return _parse(response);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationEntitlements> setLimitOverride(
    String organizationId,
    LimitKey limit, {
    required int? value,
    String? note,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }
        final response = await _pb.send(
          '/api/super-admin/organizations/$organizationId'
          '/limit-overrides/${limit.key}',
          method: 'PUT',
          body: {
            'value': value,
            if (note != null) 'note': note,
          },
        );
        return _parse(response);
      },
      Failure.handle,
    ).run();
  }
}
