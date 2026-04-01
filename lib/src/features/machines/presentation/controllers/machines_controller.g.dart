// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machines_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing machine list state.

@ProviderFor(MachinesController)
final machinesControllerProvider = MachinesControllerProvider._();

/// Controller for managing machine list state.
final class MachinesControllerProvider
    extends $AsyncNotifierProvider<MachinesController, List<Machine>> {
  /// Controller for managing machine list state.
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
    r'15110dd0e65039aec149f2b8ba71634c9e48ffd5';

/// Controller for managing machine list state.

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
