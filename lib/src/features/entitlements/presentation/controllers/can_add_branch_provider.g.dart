// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'can_add_branch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the UI may offer "Add Branch".
///
/// Without [FeatureKey.multiBranch] an organization is limited to the branch
/// it already has (the first branch is always allowed). Existing branches are
/// never removed. The server enforces the same rule.

@ProviderFor(canAddBranch)
final canAddBranchProvider = CanAddBranchProvider._();

/// Whether the UI may offer "Add Branch".
///
/// Without [FeatureKey.multiBranch] an organization is limited to the branch
/// it already has (the first branch is always allowed). Existing branches are
/// never removed. The server enforces the same rule.

final class CanAddBranchProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the UI may offer "Add Branch".
  ///
  /// Without [FeatureKey.multiBranch] an organization is limited to the branch
  /// it already has (the first branch is always allowed). Existing branches are
  /// never removed. The server enforces the same rule.
  CanAddBranchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canAddBranchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canAddBranchHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canAddBranch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canAddBranchHash() => r'8e5d21126bbf7edc8dbad32bd5a5fc620bc4295f';
