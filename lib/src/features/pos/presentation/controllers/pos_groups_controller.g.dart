// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products/services).

@ProviderFor(PosGroupsController)
final posGroupsControllerProvider = PosGroupsControllerProvider._();

/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products/services).
final class PosGroupsControllerProvider
    extends $AsyncNotifierProvider<PosGroupsController, List<PosGroup>> {
  /// Controller for managing POS groups for the current branch.
  ///
  /// Provides CRUD operations on groups and group items.
  /// Groups are loaded with their items expanded (products/services).
  PosGroupsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'posGroupsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$posGroupsControllerHash();

  @$internal
  @override
  PosGroupsController create() => PosGroupsController();
}

String _$posGroupsControllerHash() =>
    r'559e4d187710a5fc6ca66df16ed913c0d0cd3e59';

/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products/services).

abstract class _$PosGroupsController extends $AsyncNotifier<List<PosGroup>> {
  FutureOr<List<PosGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<PosGroup>>, List<PosGroup>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<PosGroup>>, List<PosGroup>>,
        AsyncValue<List<PosGroup>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
