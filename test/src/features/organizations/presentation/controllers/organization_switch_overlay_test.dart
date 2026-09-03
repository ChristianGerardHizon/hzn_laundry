import 'package:fake_async/fake_async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/features/auth/domain/auth_state.dart';
import 'package:hzn_laundry/src/features/auth/domain/user.dart';
import 'package:hzn_laundry/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_laundry/src/features/organizations/data/repositories/organization_membership_repository.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization_membership.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_laundry/src/core/foundation/type_defs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});
  group('OrganizationSwitchOverlay', () {
    test('run holds overlay until action and minimum duration complete', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        var actionDone = false;
        container.read(organizationSwitchOverlayProvider.notifier).run(
              name: 'Acme',
              action: () async {
                await Future<void>.delayed(const Duration(milliseconds: 200));
                actionDone = true;
              },
            );

        async.flushMicrotasks();
        expect(
            container.read(organizationSwitchOverlayProvider).active, isTrue);
        expect(
          container.read(organizationSwitchOverlayProvider).organizationName,
          'Acme',
        );

        async.elapse(const Duration(milliseconds: 200));
        expect(actionDone, isTrue);
        expect(
            container.read(organizationSwitchOverlayProvider).active, isTrue);

        async.elapse(OrganizationSwitchOverlay.minDuration);
        expect(
          container.read(organizationSwitchOverlayProvider).active,
          isFalse,
        );
      });
    });

    test('run is a no-op while overlay is already active', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        var calls = 0;
        container.read(organizationSwitchOverlayProvider.notifier).run(
          action: () async {
            calls++;
          },
        );
        async.flushMicrotasks();
        container.read(organizationSwitchOverlayProvider.notifier).run(
          action: () async {
            calls++;
          },
        );
        async.elapse(OrganizationSwitchOverlay.minDuration);
        expect(calls, 1);
      });
    });

    test('clears overlay if action throws', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(organizationSwitchOverlayProvider.notifier).run(
          action: () async {
            throw StateError('switch failed');
          },
        ).ignore();
        async.elapse(OrganizationSwitchOverlay.minDuration);
        expect(
          container.read(organizationSwitchOverlayProvider).active,
          isFalse,
        );
      });
    });
  });

  group('switchOrganization', () {
    final orgA = const Organization(id: 'org-a', name: 'Alpha');
    final orgB = const Organization(id: 'org-b', name: 'Beta');
    final memberships = [
      OrganizationMembership(
        id: 'm-a',
        organizationId: orgA.id,
        userId: 'user-1',
        status: 'active',
        joinedAt: DateTime.utc(2026, 1, 1),
        organization: orgA,
      ),
      OrganizationMembership(
        id: 'm-b',
        organizationId: orgB.id,
        userId: 'user-1',
        status: 'active',
        joinedAt: DateTime.utc(2026, 1, 1),
        organization: orgB,
      ),
    ];

    const auth = AuthState(
      token: 'token',
      user: User(id: 'user-1', name: 'Test', email: 'test@example.com'),
    );

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          currentAuthProvider.overrideWithValue(auth),
          organizationMembershipRepositoryProvider.overrideWithValue(
            _FakeMembershipRepository(memberships),
          ),
        ],
      );
    }

    test('same-id switch does not activate the overlay', () async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(currentOrganizationControllerProvider.future);
      expect(
        container.read(currentOrganizationControllerProvider).value?.id,
        orgA.id,
      );

      await container
          .read(currentOrganizationControllerProvider.notifier)
          .switchOrganization(orgA.id);

      expect(container.read(organizationSwitchOverlayProvider).active, isFalse);
    });
  });
}

class _FakeMembershipRepository implements OrganizationMembershipRepository {
  _FakeMembershipRepository(this.memberships);

  final List<OrganizationMembership> memberships;

  @override
  FutureEither<List<OrganizationMembership>> listMine(String userId) async {
    return Right(memberships);
  }

  @override
  FutureEither<List<OrganizationMembership>> listForOrganization(
    String orgId,
  ) async {
    return Right(
      memberships.where((m) => m.organizationId == orgId).toList(),
    );
  }
}
