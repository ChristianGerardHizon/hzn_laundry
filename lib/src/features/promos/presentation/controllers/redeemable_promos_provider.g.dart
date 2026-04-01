// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeemable_promos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).

@ProviderFor(redeemablePromos)
final redeemablePromosProvider = RedeemablePromosFamily._();

/// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).

final class RedeemablePromosProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerPromo>>,
        List<CustomerPromo>,
        FutureOr<List<CustomerPromo>>>
    with
        $FutureModifier<List<CustomerPromo>>,
        $FutureProvider<List<CustomerPromo>> {
  /// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).
  RedeemablePromosProvider._(
      {required RedeemablePromosFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'redeemablePromosProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$redeemablePromosHash();

  @override
  String toString() {
    return r'redeemablePromosProvider'
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
    return redeemablePromos(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RedeemablePromosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$redeemablePromosHash() => r'9a7c77824be77584ddc1e76629e1ac4d6679b3af';

/// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).

final class RedeemablePromosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CustomerPromo>>, String> {
  RedeemablePromosFamily._()
      : super(
          retry: null,
          name: r'redeemablePromosProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).

  RedeemablePromosProvider call(
    String customerId,
  ) =>
      RedeemablePromosProvider._(argument: customerId, from: this);

  @override
  String toString() => r'redeemablePromosProvider';
}
