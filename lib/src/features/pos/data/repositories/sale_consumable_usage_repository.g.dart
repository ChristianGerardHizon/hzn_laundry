// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_consumable_usage_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleConsumableUsageRepository)
final saleConsumableUsageRepositoryProvider =
    SaleConsumableUsageRepositoryProvider._();

final class SaleConsumableUsageRepositoryProvider extends $FunctionalProvider<
        SaleConsumableUsageRepository,
        SaleConsumableUsageRepository,
        SaleConsumableUsageRepository>
    with $Provider<SaleConsumableUsageRepository> {
  SaleConsumableUsageRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'saleConsumableUsageRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleConsumableUsageRepositoryHash();

  @$internal
  @override
  $ProviderElement<SaleConsumableUsageRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaleConsumableUsageRepository create(Ref ref) {
    return saleConsumableUsageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleConsumableUsageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<SaleConsumableUsageRepository>(value),
    );
  }
}

String _$saleConsumableUsageRepositoryHash() =>
    r'72871a25f71dc6d2497e4facf34e83b926f5b2f1';
