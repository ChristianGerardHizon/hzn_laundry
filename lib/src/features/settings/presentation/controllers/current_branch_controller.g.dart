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

@ProviderFor(CurrentBranchController)
final currentBranchControllerProvider = CurrentBranchControllerProvider._();

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
final class CurrentBranchControllerProvider
    extends $AsyncNotifierProvider<CurrentBranchController, Branch?> {
  /// Controller for managing the current working branch.
  ///
  /// - For admins: Allows switching between branches (or All Branches), persists selection
  /// - For regular users: Locked to their assigned branch
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
    r'c0dfecbd549d252951962a2bf7040cafad84b0dc';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch

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
/// Returns a filter string like `branch = "id"` or null if All Branches / none.

@ProviderFor(currentBranchFilter)
final currentBranchFilterProvider = CurrentBranchFilterProvider._();

/// Convenience provider for branch filter string.
///
/// Returns a filter string like `branch = "id"` or null if All Branches / none.

final class CurrentBranchFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for branch filter string.
  ///
  /// Returns a filter string like `branch = "id"` or null if All Branches / none.
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
    r'ff9f628f86fd25ae80daf902e8b4a25457a0c5ba';
