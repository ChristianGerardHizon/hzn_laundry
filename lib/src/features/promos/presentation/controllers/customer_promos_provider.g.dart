// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_promos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a customer's enrolled promos.

@ProviderFor(customerPromos)
final customerPromosProvider = CustomerPromosFamily._();

/// Provider for a customer's enrolled promos.

final class CustomerPromosProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerPromo>>,
        List<CustomerPromo>,
        FutureOr<List<CustomerPromo>>>
    with
        $FutureModifier<List<CustomerPromo>>,
        $FutureProvider<List<CustomerPromo>> {
  /// Provider for a customer's enrolled promos.
  CustomerPromosProvider._(
      {required CustomerPromosFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'customerPromosProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerPromosHash();

  @override
  String toString() {
    return r'customerPromosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CustomerPromo>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerPromo>> create(Ref ref) {
    final argument = this.argument as String;
    return customerPromos(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerPromosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerPromosHash() => r'bcc731cc9f7623708a79827ca57b1ac299598757';

/// Provider for a customer's enrolled promos.

final class CustomerPromosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CustomerPromo>>, String> {
  CustomerPromosFamily._()
      : super(
          retry: null,
          name: r'customerPromosProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a customer's enrolled promos.

  CustomerPromosProvider call(
    String customerId,
  ) =>
      CustomerPromosProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerPromosProvider';
}
