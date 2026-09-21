import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/router_utils.dart';
import 'package:hzn_laundry/src/core/routing/routes/auth.routes.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_laundry/src/features/settings/domain/branch.dart';
import 'package:hzn_laundry/src/features/settings/presentation/controllers/current_branch_controller.dart';

/// Captures a [Ref] from a [ProviderContainer] for calling RouterUtils helpers.
final _refCaptureProvider = Provider<Ref>((ref) => ref);

void main() {
  const orgA = Organization(id: 'org-a', name: 'Alpha', slug: 'alpha');
  const orgB = Organization(id: 'org-b', name: 'Beta', slug: 'beta');
  const branchB = Branch(
    id: 'branch-b',
    name: 'Main',
    slug: 'main',
    address: '1 Main St',
    contactNumber: '123',
    organizationId: 'org-b',
  );

  ProviderContainer buildContainer({
    required CurrentOrganizationController Function() org,
    required CurrentBranchController Function() branch,
  }) {
    return ProviderContainer(
      overrides: [
        currentOrganizationControllerProvider.overrideWith(org),
        currentBranchControllerProvider.overrideWith(branch),
      ],
    );
  }

  group('RouterUtils.resolveOrgSlugMismatch', () {
    test(
      'returns null when org switched but branch still loading '
      '(stale URL org slug)',
      () async {
        final container = buildContainer(
          org: () => _FixedOrgController(orgB),
          branch: _LoadingBranchController.new,
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        // Kick branch into AsyncLoading without awaiting completion.
        container.read(currentBranchControllerProvider);
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(currentOrganizationControllerProvider).isLoading,
          isFalse,
        );
        expect(
          container.read(currentBranchControllerProvider).isLoading,
          isTrue,
        );

        final result = RouterUtils.resolveOrgSlugMismatch(
          ref: container.read(_refCaptureProvider),
          orgSlug: orgA.slug,
          branchSlug: allBranchesSlug,
          currentPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uriPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uri: Uri(path: '/${orgA.slug}/$allBranchesSlug/dashboard'),
        );

        expect(result, isNull);
        expect(result, isNot(ScopeRecoveryRoute.path));
      },
    );

    test(
      'returns ScopeRecovery when scope is settled but unresolvable',
      () async {
        final container = buildContainer(
          org: () => _FixedOrgController(null),
          branch: () => _FixedBranchController(null),
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        await container.read(currentBranchControllerProvider.future);

        final result = RouterUtils.resolveOrgSlugMismatch(
          ref: container.read(_refCaptureProvider),
          orgSlug: orgA.slug,
          branchSlug: allBranchesSlug,
          currentPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uriPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uri: Uri(path: '/${orgA.slug}/$allBranchesSlug/dashboard'),
        );

        expect(result, ScopeRecoveryRoute.path);
      },
    );

    test(
      'returns null while org-switch overlay is active even if scope settled',
      () async {
        final container = buildContainer(
          org: () => _FixedOrgController(null),
          branch: () => _FixedBranchController(null),
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        await container.read(currentBranchControllerProvider.future);

        // Activate overlay without awaiting completion.
        unawaited(
          container.read(organizationSwitchOverlayProvider.notifier).run(
                name: 'Beta',
                action: () => Completer<void>().future,
              ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(
          container.read(organizationSwitchOverlayProvider).active,
          isTrue,
        );

        final result = RouterUtils.resolveOrgSlugMismatch(
          ref: container.read(_refCaptureProvider),
          orgSlug: orgA.slug,
          branchSlug: allBranchesSlug,
          currentPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uriPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uri: Uri(path: '/${orgA.slug}/$allBranchesSlug/dashboard'),
        );

        expect(result, isNull);
      },
    );

    test(
      'rewrites path to current org when scope is ready',
      () async {
        final container = buildContainer(
          org: () => _FixedOrgController(orgB),
          branch: () => _FixedBranchController(branchB),
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        await container.read(currentBranchControllerProvider.future);

        final result = RouterUtils.resolveOrgSlugMismatch(
          ref: container.read(_refCaptureProvider),
          orgSlug: orgA.slug,
          branchSlug: allBranchesSlug,
          currentPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uriPath: '/${orgA.slug}/$allBranchesSlug/dashboard',
          uri: Uri(path: '/${orgA.slug}/$allBranchesSlug/dashboard'),
        );

        expect(result, '/${orgB.slug}/${branchB.slug}/dashboard');
      },
    );
  });
}

class _FixedOrgController extends CurrentOrganizationController {
  _FixedOrgController(this.org);

  final Organization? org;

  @override
  Future<Organization?> build() async => org;
}

class _FixedBranchController extends CurrentBranchController {
  _FixedBranchController(this.branch);

  final Branch? branch;

  @override
  Future<Branch?> build() async => branch;
}

class _LoadingBranchController extends CurrentBranchController {
  @override
  Future<Branch?> build() => Completer<Branch?>().future;
}
