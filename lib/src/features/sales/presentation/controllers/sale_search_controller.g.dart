// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for sale search query state.

@ProviderFor(SaleSearchQuery)
final saleSearchQueryProvider = SaleSearchQueryProvider._();

/// Provider for sale search query state.
final class SaleSearchQueryProvider
    extends $NotifierProvider<SaleSearchQuery, String> {
  /// Provider for sale search query state.
  SaleSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'saleSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleSearchQueryHash();

  @$internal
  @override
  SaleSearchQuery create() => SaleSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$saleSearchQueryHash() => r'5fdf399931f824994266e9d4433d2f9e92e4198c';

/// Provider for sale search query state.

abstract class _$SaleSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for managing which fields are included in sale search.

@ProviderFor(SaleSearchFields)
final saleSearchFieldsProvider = SaleSearchFieldsProvider._();

/// Provider for managing which fields are included in sale search.
final class SaleSearchFieldsProvider
    extends $NotifierProvider<SaleSearchFields, Set<String>> {
  /// Provider for managing which fields are included in sale search.
  SaleSearchFieldsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'saleSearchFieldsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleSearchFieldsHash();

  @$internal
  @override
  SaleSearchFields create() => SaleSearchFields();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$saleSearchFieldsHash() => r'6fc609f3c504d2cebcd788c28cf7ad02a5fae07c';

/// Provider for managing which fields are included in sale search.

abstract class _$SaleSearchFields extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for paid / unpaid / payment-method list filters.

@ProviderFor(SalePaymentFiltersController)
final salePaymentFiltersControllerProvider =
    SalePaymentFiltersControllerProvider._();

/// Provider for paid / unpaid / payment-method list filters.
final class SalePaymentFiltersControllerProvider extends $NotifierProvider<
    SalePaymentFiltersController, SalePaymentFilters> {
  /// Provider for paid / unpaid / payment-method list filters.
  SalePaymentFiltersControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salePaymentFiltersControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salePaymentFiltersControllerHash();

  @$internal
  @override
  SalePaymentFiltersController create() => SalePaymentFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalePaymentFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalePaymentFilters>(value),
    );
  }
}

String _$salePaymentFiltersControllerHash() =>
    r'0eb278f7306eadc8a18ee14101e415ad8dac321d';

/// Provider for paid / unpaid / payment-method list filters.

abstract class _$SalePaymentFiltersController
    extends $Notifier<SalePaymentFilters> {
  SalePaymentFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SalePaymentFilters, SalePaymentFilters>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SalePaymentFilters, SalePaymentFilters>,
        SalePaymentFilters,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
