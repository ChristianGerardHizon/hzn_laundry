import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/organization_membership.dart';
import '../dto/organization_membership_dto.dart';

part 'organization_membership_repository.g.dart';

abstract class OrganizationMembershipRepository {
  FutureEither<List<OrganizationMembership>> listMine(String userId);
  FutureEither<List<OrganizationMembership>> listForOrganization(String orgId);
}

@Riverpod(keepAlive: true)
OrganizationMembershipRepository organizationMembershipRepository(Ref ref) {
  return OrganizationMembershipRepositoryImpl(ref.watch(pocketbaseProvider));
}

class OrganizationMembershipRepositoryImpl
    implements OrganizationMembershipRepository {
  OrganizationMembershipRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.organizationMemberships);

  static const _expand = 'organization,role';

  @override
  FutureEither<List<OrganizationMembership>> listMine(String userId) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .relation('user', userId)
            .equals('status', 'active')
            .build();
        final records = await _collection.getFullList(
          filter: filter,
          expand: _expand,
          sort: 'joinedAt',
        );
        return records
            .map(OrganizationMembershipDto.fromRecord)
            .map((dto) => dto.toEntity())
            .toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<OrganizationMembership>> listForOrganization(
    String orgId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .relation('organization', orgId)
            .equals('status', 'active')
            .build();
        final records = await _collection.getFullList(
          filter: filter,
          expand: _expand,
          sort: 'joinedAt',
        );
        return records
            .map(OrganizationMembershipDto.fromRecord)
            .map((dto) => dto.toEntity())
            .toList();
      },
      Failure.handle,
    ).run();
  }
}
