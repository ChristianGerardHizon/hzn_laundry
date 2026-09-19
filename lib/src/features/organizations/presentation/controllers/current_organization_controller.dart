import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/organization_membership_repository.dart';
import '../../domain/organization.dart';
import '../../domain/organization_membership.dart';
import 'organization_scope_refresh.dart';

part 'current_organization_controller.g.dart';

const _currentOrganizationStorageKey = 'CURRENT_ORGANIZATION_ID';

/// Whether the full-screen org/branch-switch loader is showing.
class OrganizationSwitchOverlayState {
  const OrganizationSwitchOverlayState({
    this.active = false,
    this.targetName,
    this.organizationLabel,
  });

  final bool active;

  /// Display name of the org or branch being switched to (message text).
  final String? targetName;

  /// Organization name for the letter-mark badge (destination org).
  final String? organizationLabel;

  /// Alias for older call sites / tests.
  String? get organizationName => targetName;
}

/// Keep-alive flag for the org/branch-switch full-screen overlay.
@Riverpod(keepAlive: true)
class OrganizationSwitchOverlay extends _$OrganizationSwitchOverlay {
  static const minDuration = Duration(seconds: 2);

  @override
  OrganizationSwitchOverlayState build() =>
      const OrganizationSwitchOverlayState();

  /// Shows the overlay until [action] and [minDuration] both complete.
  Future<void> run({
    String? name,
    String? organizationLabel,
    required Future<void> Function() action,
  }) async {
    if (state.active) return;
    state = OrganizationSwitchOverlayState(
      active: true,
      targetName: name,
      organizationLabel: organizationLabel ?? name,
    );
    try {
      await Future.wait([
        action(),
        Future<void>.delayed(minDuration),
      ]);
    } finally {
      state = const OrganizationSwitchOverlayState();
    }
  }
}

@Riverpod(keepAlive: true)
class CurrentOrganizationController extends _$CurrentOrganizationController {
  List<OrganizationMembership> _memberships = const [];

  List<OrganizationMembership> get memberships => _memberships;

  bool get canSwitchOrganization => _memberships.length > 1;

  List<Organization> switchableOrganizations() {
    return _memberships
        .map((m) => m.organization)
        .whereType<Organization>()
        .toList();
  }

  OrganizationMembership? membershipFor(String organizationId) {
    for (final membership in _memberships) {
      if (membership.organizationId == organizationId) return membership;
    }
    return null;
  }

  @override
  Future<Organization?> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) {
      _memberships = const [];
      return null;
    }

    final result = await ref
        .read(organizationMembershipRepositoryProvider)
        .listMine(auth.user.id);

    final memberships =
        result.fold((failure) => throw failure, (value) => value);
    _memberships = memberships;
    if (memberships.isEmpty) return null;
    if (memberships.length == 1) {
      return memberships.first.organization;
    }

    final persistedId = await _loadPersistedOrganization();
    final match = memberships.cast<OrganizationMembership?>().firstWhere(
          (m) => m?.organizationId == persistedId,
          orElse: () => null,
        );
    return (match ?? memberships.first).organization;
  }

  Future<void> switchOrganization(String id) async {
    if (!canSwitchOrganization) return;
    if (state.value?.id == id) return;
    final name = membershipFor(id)?.organization?.name;
    await ref.read(organizationSwitchOverlayProvider.notifier).run(
          name: name,
          action: () => selectOrganization(id),
        );
  }

  /// Persist [id] and reload memberships. Used after creating an org so the
  /// new tenant is selected even when the user did not previously belong to
  /// more than one organization.
  Future<void> selectOrganization(String id) async {
    await _persistOrganization(id);
    ref.invalidateSelf();
    await future;
    invalidateOrganizationScopedProviders(ref);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<String?> _loadPersistedOrganization() async {
    try {
      final storage = ref.read(secureStorageProvider);
      return await storage.read(key: _currentOrganizationStorageKey);
    } catch (e, st) {
      assert(() {
        debugPrint('Failed to load persisted organization: $e\n$st');
        return true;
      }());
      return null;
    }
  }

  Future<void> _persistOrganization(String organizationId) async {
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(
        key: _currentOrganizationStorageKey,
        value: organizationId,
      );
    } catch (e, st) {
      assert(() {
        debugPrint('Failed to persist organization: $e\n$st');
        return true;
      }());
    }
  }
}

@Riverpod(keepAlive: true)
String? currentOrganizationId(Ref ref) {
  return ref.watch(currentOrganizationControllerProvider).value?.id;
}

@Riverpod(keepAlive: true)
bool canSwitchOrganization(Ref ref) {
  ref.watch(currentOrganizationControllerProvider);
  return ref
      .read(currentOrganizationControllerProvider.notifier)
      .canSwitchOrganization;
}
