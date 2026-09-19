// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_branch_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
/// - Once a validated route scope exists, the URL is the source of truth

@ProviderFor(CurrentBranchController)
final currentBranchControllerProvider = CurrentBranchControllerProvider._();

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
/// - Once a validated route scope exists, the URL is the source of truth
final class CurrentBranchControllerProvider
    extends $AsyncNotifierProvider<CurrentBranchController, Branch?> {
  /// Controller for managing the current working branch.
  ///
  /// - For admins: Allows switching between branches (or All Branches), persists selection
  /// - For regular users: Locked to their assigned branch
  /// - Once a validated route scope exists, the URL is the source of truth
  CurrentBranchControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBranchControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBranchControllerHash();

  @$internal
  @override
  CurrentBranchController create() => CurrentBranchController();
}

String _$currentBranchControllerHash() =>
    r'ed4bc77ae08703f35034a8ae280c93a60207f365';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
/// - Once a validated route scope exists, the URL is the source of truth

abstract class _$CurrentBranchController extends $AsyncNotifier<Branch?> {
  FutureOr<Branch?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Branch?>, Branch?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Branch?>, Branch?>,
        AsyncValue<Branch?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Whether the admin has selected All Branches mode.

@ProviderFor(isAllBranches)
final isAllBranchesProvider = IsAllBranchesProvider._();

/// Whether the admin has selected All Branches mode.

final class IsAllBranchesProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the admin has selected All Branches mode.
  IsAllBranchesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAllBranchesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAllBranchesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAllBranches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAllBranchesHash() => r'a19f6940de9c8c75bf0116d63b717d22ebc2bb61';

/// Convenience provider for current branch ID.
///
/// Returns null when All Branches is selected or no branch is available.

@ProviderFor(currentBranchId)
final currentBranchIdProvider = CurrentBranchIdProvider._();

/// Convenience provider for current branch ID.
///
/// Returns null when All Branches is selected or no branch is available.

final class CurrentBranchIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for current branch ID.
  ///
  /// Returns null when All Branches is selected or no branch is available.
  CurrentBranchIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBranchIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBranchIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchIdHash() => r'dd457fa7bdc31f57c2153247e3976e7a0f88db10';

/// Convenience provider for branch filter string.
///
/// - Specific branch: `branch = "id" && isDeleted = false`
/// - All Branches + current org: `branch.organization = "orgId"`
/// - No org selected: null

@ProviderFor(currentBranchFilter)
final currentBranchFilterProvider = CurrentBranchFilterProvider._();

/// Convenience provider for branch filter string.
///
/// - Specific branch: `branch = "id" && isDeleted = false`
/// - All Branches + current org: `branch.organization = "orgId"`
/// - No org selected: null

final class CurrentBranchFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for branch filter string.
  ///
  /// - Specific branch: `branch = "id" && isDeleted = false`
  /// - All Branches + current org: `branch.organization = "orgId"`
  /// - No org selected: null
  CurrentBranchFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBranchFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBranchFilterHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchFilterHash() =>
    r'ded21ccf145d4fc797a55b512252053c91bbe59e';

/// Same scope as [currentBranchFilter] but without soft-delete, for appending
/// to existing filter strings (` && …`).

@ProviderFor(currentBranchScopeClause)
final currentBranchScopeClauseProvider = CurrentBranchScopeClauseProvider._();

/// Same scope as [currentBranchFilter] but without soft-delete, for appending
/// to existing filter strings (` && …`).

final class CurrentBranchScopeClauseProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  /// Same scope as [currentBranchFilter] but without soft-delete, for appending
  /// to existing filter strings (` && …`).
  CurrentBranchScopeClauseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBranchScopeClauseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBranchScopeClauseHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currentBranchScopeClause(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentBranchScopeClauseHash() =>
    r'b288be9202f3eb0e85516ec1cfb7be19840744f8';

/// Payment / nested-sale scope: `sale.branch = "id"` or
/// `sale.branch.organization = "orgId"`.

@ProviderFor(currentSaleBranchScopeClause)
final currentSaleBranchScopeClauseProvider =
    CurrentSaleBranchScopeClauseProvider._();

/// Payment / nested-sale scope: `sale.branch = "id"` or
/// `sale.branch.organization = "orgId"`.

final class CurrentSaleBranchScopeClauseProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  /// Payment / nested-sale scope: `sale.branch = "id"` or
  /// `sale.branch.organization = "orgId"`.
  CurrentSaleBranchScopeClauseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentSaleBranchScopeClauseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentSaleBranchScopeClauseHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currentSaleBranchScopeClause(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentSaleBranchScopeClauseHash() =>
    r'11adbf0a5ca7c89ed3c8426e6b33e08636c6f40f';

/// Flat branch-id filter for SQL views (no relation traversal).
///
/// - Specific branch: `branch = "id"`
/// - All Branches: `(branch = "a" || branch = "b" || …)` for current org

@ProviderFor(currentBranchIdsFilter)
final currentBranchIdsFilterProvider = CurrentBranchIdsFilterProvider._();

/// Flat branch-id filter for SQL views (no relation traversal).
///
/// - Specific branch: `branch = "id"`
/// - All Branches: `(branch = "a" || branch = "b" || …)` for current org

final class CurrentBranchIdsFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Flat branch-id filter for SQL views (no relation traversal).
  ///
  /// - Specific branch: `branch = "id"`
  /// - All Branches: `(branch = "a" || branch = "b" || …)` for current org
  CurrentBranchIdsFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBranchIdsFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBranchIdsFilterHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchIdsFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchIdsFilterHash() =>
    r'd69837bd56542dbd8cf499161612ca4bb1893e1f';
