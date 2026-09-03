import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/organization_invite.dart';
import '../../domain/organization_membership.dart';
import '../dto/organization_invite_dto.dart';
import '../dto/organization_membership_dto.dart';

part 'organization_invite_repository.g.dart';

abstract class OrganizationInviteRepository {
  FutureEither<OrganizationInvite> create({
    required String organizationId,
    required String email,
    required String roleId,
  });
  FutureEither<OrganizationMembership> accept(String inviteId);
  FutureEither<OrganizationInvite> revoke(String inviteId);
  FutureEither<OrganizationInvite> decline(String inviteId);
  FutureEither<List<OrganizationInvite>> listMine(String email);
  FutureEither<List<OrganizationInvite>> listForOrganization(String orgId);
}

@Riverpod(keepAlive: true)
OrganizationInviteRepository organizationInviteRepository(Ref ref) {
  return OrganizationInviteRepositoryImpl(ref.watch(pocketbaseProvider));
}

class OrganizationInviteRepositoryImpl implements OrganizationInviteRepository {
  OrganizationInviteRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.organizationInvites);

  Map<String, dynamic> _asMap(dynamic response, String code) {
    if (response is Map<String, dynamic>) return response;
    throw DataFailure('Invalid invite response', null, code);
  }

  @override
  FutureEither<OrganizationInvite> create({
    required String organizationId,
    required String email,
    required String roleId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/organization-invites',
          method: 'POST',
          body: {
            'organization': organizationId,
            'email': email.trim().toLowerCase(),
            'role': roleId,
          },
        );
        return OrganizationInviteDto.fromJson(
          _asMap(response, 'invalid_invite_create_response'),
        ).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationMembership> accept(String inviteId) async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/organization-invites/$inviteId/accept',
          method: 'POST',
        );
        return OrganizationMembershipDto.fromRecord(
          RecordModel.fromJson(
            _asMap(response, 'invalid_invite_accept_response'),
          ),
        ).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationInvite> revoke(String inviteId) async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/organization-invites/$inviteId/revoke',
          method: 'POST',
        );
        return OrganizationInviteDto.fromJson(
          _asMap(response, 'invalid_invite_revoke_response'),
        ).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationInvite> decline(String inviteId) async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/organization-invites/$inviteId/decline',
          method: 'POST',
        );
        return OrganizationInviteDto.fromJson(
          _asMap(response, 'invalid_invite_decline_response'),
        ).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<OrganizationInvite>> listMine(String email) async {
    return TaskEither.tryCatch(
      () async {
        final trimmed = email.trim().toLowerCase();
        if (trimmed.isEmpty) return <OrganizationInvite>[];
        final filter = PBFilter()
            .equals('email', trimmed)
            .equals('status', 'pending')
            .build();
        final records = await _collection.getFullList(
          filter: filter,
          expand: 'organization,role',
          sort: '-created',
        );
        return records
            .map(OrganizationInviteDto.fromRecord)
            .map((dto) => dto.toEntity())
            .toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<OrganizationInvite>> listForOrganization(
    String orgId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .relation('organization', orgId)
            .equals('status', 'pending')
            .build();
        final records = await _collection.getFullList(
          filter: filter,
          expand: 'organization,role',
          sort: '-created',
        );
        return records
            .map(OrganizationInviteDto.fromRecord)
            .map((dto) => dto.toEntity())
            .toList();
      },
      Failure.handle,
    ).run();
  }
}
