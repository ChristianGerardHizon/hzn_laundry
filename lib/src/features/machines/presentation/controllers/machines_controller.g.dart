// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machines_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing machine list state.
///
/// Machines are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch machines are
/// excluded so they cannot leak across orgs.

@ProviderFor(MachinesController)
final machinesControllerProvider = MachinesControllerProvider._();

/// Controller for managing machine list state.
///
/// Machines are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch machines are
/// excluded so they cannot leak across orgs.
final class MachinesControllerProvider
    extends $AsyncNotifierProvider<MachinesController, List<Machine>> {
  /// Controller for managing machine list state.
  ///
  /// Machines are scoped to the selected branch, or all branches of the current
  /// organization when All Branches is selected. Blank-branch machines are
  /// excluded so they cannot leak across orgs.
  MachinesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'machinesControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$machinesControllerHash();

  @$internal
  @override
  MachinesController create() => MachinesController();
}

String _$machinesControllerHash() =>
    r'14bae0b6a018637e2636c9a7cd393d053b7f7c86';

/// Controller for managing machine list state.
///
/// Machines are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch machines are
/// excluded so they cannot leak across orgs.

abstract class _$MachinesController extends $AsyncNotifier<List<Machine>> {
  FutureOr<List<Machine>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Machine>>, List<Machine>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Machine>>, List<Machine>>,
        AsyncValue<List<Machine>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
