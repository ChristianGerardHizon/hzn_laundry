// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machines_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing machine list state.
///
/// Machines are scoped to the current working branch. Unassigned machines
/// (no branch set) remain visible so existing org-wide records are not hidden.

@ProviderFor(MachinesController)
final machinesControllerProvider = MachinesControllerProvider._();

/// Controller for managing machine list state.
///
/// Machines are scoped to the current working branch. Unassigned machines
/// (no branch set) remain visible so existing org-wide records are not hidden.
final class MachinesControllerProvider
    extends $AsyncNotifierProvider<MachinesController, List<Machine>> {
  /// Controller for managing machine list state.
  ///
  /// Machines are scoped to the current working branch. Unassigned machines
  /// (no branch set) remain visible so existing org-wide records are not hidden.
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
    r'fb94e7777a9457de7cce0b5265b4d629b234c61c';

/// Controller for managing machine list state.
///
/// Machines are scoped to the current working branch. Unassigned machines
/// (no branch set) remain visible so existing org-wide records are not hidden.

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
