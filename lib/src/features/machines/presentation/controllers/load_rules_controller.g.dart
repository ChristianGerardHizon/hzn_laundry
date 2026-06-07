// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_rules_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the load rules of a single machine.
///
/// Keyed by [machineId] so each machine's rules are tracked independently.

@ProviderFor(LoadRulesController)
final loadRulesControllerProvider = LoadRulesControllerFamily._();

/// Controller for managing the load rules of a single machine.
///
/// Keyed by [machineId] so each machine's rules are tracked independently.
final class LoadRulesControllerProvider
    extends $AsyncNotifierProvider<LoadRulesController, List<LoadRule>> {
  /// Controller for managing the load rules of a single machine.
  ///
  /// Keyed by [machineId] so each machine's rules are tracked independently.
  LoadRulesControllerProvider._(
      {required LoadRulesControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'loadRulesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadRulesControllerHash();

  @override
  String toString() {
    return r'loadRulesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LoadRulesController create() => LoadRulesController();

  @override
  bool operator ==(Object other) {
    return other is LoadRulesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loadRulesControllerHash() =>
    r'7107fd00736698303087e7b5671b06062c331ad0';

/// Controller for managing the load rules of a single machine.
///
/// Keyed by [machineId] so each machine's rules are tracked independently.

final class LoadRulesControllerFamily extends $Family
    with
        $ClassFamilyOverride<LoadRulesController, AsyncValue<List<LoadRule>>,
            List<LoadRule>, FutureOr<List<LoadRule>>, String> {
  LoadRulesControllerFamily._()
      : super(
          retry: null,
          name: r'loadRulesControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing the load rules of a single machine.
  ///
  /// Keyed by [machineId] so each machine's rules are tracked independently.

  LoadRulesControllerProvider call(
    String machineId,
  ) =>
      LoadRulesControllerProvider._(argument: machineId, from: this);

  @override
  String toString() => r'loadRulesControllerProvider';
}

/// Controller for managing the load rules of a single machine.
///
/// Keyed by [machineId] so each machine's rules are tracked independently.

abstract class _$LoadRulesController extends $AsyncNotifier<List<LoadRule>> {
  late final _$args = ref.$arg as String;
  String get machineId => _$args;

  FutureOr<List<LoadRule>> build(
    String machineId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<LoadRule>>, List<LoadRule>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<LoadRule>>, List<LoadRule>>,
        AsyncValue<List<LoadRule>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
