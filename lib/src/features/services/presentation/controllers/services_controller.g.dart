// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of services.

@ProviderFor(ServicesController)
final servicesControllerProvider = ServicesControllerProvider._();

/// Controller for managing the list of services.
final class ServicesControllerProvider
    extends $AsyncNotifierProvider<ServicesController, List<Service>> {
  /// Controller for managing the list of services.
  ServicesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'servicesControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$servicesControllerHash();

  @$internal
  @override
  ServicesController create() => ServicesController();
}

String _$servicesControllerHash() =>
    r'5e3de092a5ae8e6c5be26c44ed884d823a9772da';

/// Controller for managing the list of services.

abstract class _$ServicesController extends $AsyncNotifier<List<Service>> {
  FutureOr<List<Service>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Service>>, List<Service>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Service>>, List<Service>>,
        AsyncValue<List<Service>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
