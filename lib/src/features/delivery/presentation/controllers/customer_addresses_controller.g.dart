// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_addresses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saved delivery addresses of one customer (default first).

@ProviderFor(CustomerAddressesController)
final customerAddressesControllerProvider =
    CustomerAddressesControllerFamily._();

/// Saved delivery addresses of one customer (default first).
final class CustomerAddressesControllerProvider extends $AsyncNotifierProvider<
    CustomerAddressesController, List<CustomerAddress>> {
  /// Saved delivery addresses of one customer (default first).
  CustomerAddressesControllerProvider._(
      {required CustomerAddressesControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'customerAddressesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerAddressesControllerHash();

  @override
  String toString() {
    return r'customerAddressesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CustomerAddressesController create() => CustomerAddressesController();

  @override
  bool operator ==(Object other) {
    return other is CustomerAddressesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerAddressesControllerHash() =>
    r'c34d58c08405239ee3994aff64a60ea8445553a3';

/// Saved delivery addresses of one customer (default first).

final class CustomerAddressesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            CustomerAddressesController,
            AsyncValue<List<CustomerAddress>>,
            List<CustomerAddress>,
            FutureOr<List<CustomerAddress>>,
            String> {
  CustomerAddressesControllerFamily._()
      : super(
          retry: null,
          name: r'customerAddressesControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Saved delivery addresses of one customer (default first).

  CustomerAddressesControllerProvider call(
    String customerId,
  ) =>
      CustomerAddressesControllerProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerAddressesControllerProvider';
}

/// Saved delivery addresses of one customer (default first).

abstract class _$CustomerAddressesController
    extends $AsyncNotifier<List<CustomerAddress>> {
  late final _$args = ref.$arg as String;
  String get customerId => _$args;

  FutureOr<List<CustomerAddress>> build(
    String customerId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<CustomerAddress>>, List<CustomerAddress>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CustomerAddress>>, List<CustomerAddress>>,
        AsyncValue<List<CustomerAddress>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
