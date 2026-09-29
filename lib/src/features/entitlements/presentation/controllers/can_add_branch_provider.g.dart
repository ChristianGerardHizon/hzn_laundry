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
/// never removed. The package / Super Admin branch limit also applies. The
/// server enforces the same rules.

@ProviderFor(canAddBranch)
final canAddBranchProvider = CanAddBranchProvider._();

/// Whether the UI may offer "Add Branch".
///
/// Without [FeatureKey.multiBranch] an organization is limited to the branch
/// it already has (the first branch is always allowed). Existing branches are
/// never removed. The package / Super Admin branch limit also applies. The
/// server enforces the same rules.

final class CanAddBranchProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the UI may offer "Add Branch".
  ///
  /// Without [FeatureKey.multiBranch] an organization is limited to the branch
  /// it already has (the first branch is always allowed). Existing branches are
  /// never removed. The package / Super Admin branch limit also applies. The
  /// server enforces the same rules.
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

String _$canAddBranchHash() => r'0a67102ea7109674cad6e41995b959f0b7bc78fa';
