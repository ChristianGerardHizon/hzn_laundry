// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packages_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Super Admin list of subscription packages.

@ProviderFor(PackagesController)
final packagesControllerProvider = PackagesControllerFamily._();

/// Super Admin list of subscription packages.
final class PackagesControllerProvider extends $AsyncNotifierProvider<
    PackagesController, List<SubscriptionPackage>> {
  /// Super Admin list of subscription packages.
  PackagesControllerProvider._(
      {required PackagesControllerFamily super.from,
      required bool super.argument})
      : super(
          retry: null,
          name: r'packagesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$packagesControllerHash();

  @override
  String toString() {
    return r'packagesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PackagesController create() => PackagesController();

  @override
  bool operator ==(Object other) {
    return other is PackagesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$packagesControllerHash() =>
    r'56be1db4b844f0a83b894e220254ac9fcad1077e';

/// Super Admin list of subscription packages.

final class PackagesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            PackagesController,
            AsyncValue<List<SubscriptionPackage>>,
            List<SubscriptionPackage>,
            FutureOr<List<SubscriptionPackage>>,
            bool> {
  PackagesControllerFamily._()
      : super(
          retry: null,
          name: r'packagesControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Super Admin list of subscription packages.

  PackagesControllerProvider call({
    bool premadeOnly = false,
  }) =>
      PackagesControllerProvider._(argument: premadeOnly, from: this);

  @override
  String toString() => r'packagesControllerProvider';
}

/// Super Admin list of subscription packages.

abstract class _$PackagesController
    extends $AsyncNotifier<List<SubscriptionPackage>> {
  late final _$args = ref.$arg as bool;
  bool get premadeOnly => _$args;

  FutureOr<List<SubscriptionPackage>> build({
    bool premadeOnly = false,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SubscriptionPackage>>,
        List<SubscriptionPackage>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SubscriptionPackage>>,
            List<SubscriptionPackage>>,
        AsyncValue<List<SubscriptionPackage>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              premadeOnly: _$args,
            ));
  }
}
