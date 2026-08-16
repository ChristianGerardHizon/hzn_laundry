// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of customers.

@ProviderFor(CustomersController)
final customersControllerProvider = CustomersControllerProvider._();

/// Controller for managing the list of customers.
final class CustomersControllerProvider
    extends $AsyncNotifierProvider<CustomersController, List<Customer>> {
  /// Controller for managing the list of customers.
  CustomersControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customersControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customersControllerHash();

  @$internal
  @override
  CustomersController create() => CustomersController();
}

String _$customersControllerHash() =>
    r'64ee623b3efe590a5f9e6b41778f1d8adb66ba4b';

/// Controller for managing the list of customers.

abstract class _$CustomersController extends $AsyncNotifier<List<Customer>> {
  FutureOr<List<Customer>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Customer>>, List<Customer>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Customer>>, List<Customer>>,
        AsyncValue<List<Customer>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
