import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/organization.dart';
import '../../domain/organization_platform_stats.dart';
import '../../domain/organization_setup.dart';
import '../dto/organization_dto.dart';
import '../dto/organization_platform_stats_dto.dart';

part 'organization_repository.g.dart';

abstract class OrganizationRepository {
  FutureEither<Organization> get(String id);
  FutureEither<Organization> create({
    required String name,
    String? contactNumber,
    String? address,
    required OrganizationSetupBranch branch,
    List<OrganizationSetupInvite> invites,
    String? packageId,
    Map<String, dynamic>? customPackage,
  });
  FutureEither<Organization> update(
    String id, {
    String? name,
    String? contactNumber,
    String? address,
    DateTime? onboardingCompletedAt,
  });

  /// Platform-wide org metrics for `system.admin` (Super Admin dashboard).
  FutureEither<OrganizationPlatformStatsResponse> listPlatformStats();
}

@Riverpod(keepAlive: true)
OrganizationRepository organizationRepository(Ref ref) {
  return OrganizationRepositoryImpl(ref.watch(pocketbaseProvider));
}

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.organizations);

  Organization _fromMap(Map<String, dynamic> json) {
    return OrganizationDto.fromJson(json).toEntity();
  }

  @override
  FutureEither<Organization> get(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }
        final record = await _collection.getOne(id);
        return OrganizationDto.fromRecord(record).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> create({
    required String name,
    String? contactNumber,
    String? address,
    required OrganizationSetupBranch branch,
    List<OrganizationSetupInvite> invites = const [],
    String? packageId,
    Map<String, dynamic>? customPackage,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final hasPackage =
            (packageId != null && packageId.isNotEmpty) || customPackage != null;
        if (!hasPackage) {
          throw const DataFailure(
            'A subscription package is required',
            null,
            'subscription_package_required',
          );
        }

        final response = await _pb.send(
          '/api/organizations',
          method: 'POST',
          body: {
            'name': name,
            'contactNumber': contactNumber ?? '',
            'address': address ?? '',
            'branch': branch.toJson(),
            'invites': invites.map((i) => i.toJson()).toList(),
            if (packageId != null && packageId.isNotEmpty) 'packageId': packageId,
            if (customPackage != null) 'customPackage': customPackage,
          },
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization create response',
            null,
            'invalid_organization_response',
          );
        }
        return _fromMap(response);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> update(
    String id, {
    String? name,
    String? contactNumber,
    String? address,
    DateTime? onboardingCompletedAt,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final body = <String, dynamic>{};
        if (name != null) body['name'] = name;
        if (contactNumber != null) body['contactNumber'] = contactNumber;
        if (address != null) body['address'] = address;
        if (onboardingCompletedAt != null) {
          body['onboardingCompletedAt'] =
              onboardingCompletedAt.toUtc().toIso8601String();
        }

        final response = await _pb.send(
          '/api/organizations/$id',
          method: 'PATCH',
          body: body,
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization update response',
            null,
            'invalid_organization_response',
          );
        }
        return _fromMap(response);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationPlatformStatsResponse> listPlatformStats() async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/super-admin/organization-stats',
          method: 'GET',
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization stats response',
            null,
            'invalid_organization_stats_response',
          );
        }
        return OrganizationPlatformStatsResponseDto.fromJson(response)
            .toEntity();
      },
      Failure.handle,
    ).run();
  }
}
