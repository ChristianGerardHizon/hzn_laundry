// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single promo by ID.

@ProviderFor(promo)
final promoProvider = PromoFamily._();

/// Provider for a single promo by ID.

final class PromoProvider
    extends $FunctionalProvider<AsyncValue<Promo?>, Promo?, FutureOr<Promo?>>
    with $FutureModifier<Promo?>, $FutureProvider<Promo?> {
  /// Provider for a single promo by ID.
  PromoProvider._(
      {required PromoFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'promoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promoHash();

  @override
  String toString() {
    return r'promoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Promo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Promo?> create(Ref ref) {
    final argument = this.argument as String;
    return promo(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PromoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$promoHash() => r'8303a771a1cae4a906892f51090f0048bbfd6bc1';

/// Provider for a single promo by ID.

final class PromoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Promo?>, String> {
  PromoFamily._()
      : super(
          retry: null,
          name: r'promoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single promo by ID.

  PromoProvider call(
    String id,
  ) =>
      PromoProvider._(argument: id, from: this);

  @override
  String toString() => r'promoProvider';
}
