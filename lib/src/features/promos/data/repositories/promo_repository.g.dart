// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the PromoRepository instance.

@ProviderFor(promoRepository)
final promoRepositoryProvider = PromoRepositoryProvider._();

/// Provides the PromoRepository instance.

final class PromoRepositoryProvider extends $FunctionalProvider<PromoRepository,
    PromoRepository, PromoRepository> with $Provider<PromoRepository> {
  /// Provides the PromoRepository instance.
  PromoRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'promoRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promoRepositoryHash();

  @$internal
  @override
  $ProviderElement<PromoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PromoRepository create(Ref ref) {
    return promoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromoRepository>(value),
    );
  }
}

String _$promoRepositoryHash() => r'265903f6a2ab4cc6431026726c7b2198933ae584';
