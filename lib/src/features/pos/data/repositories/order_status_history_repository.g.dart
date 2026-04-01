// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_status_history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the OrderStatusHistoryRepository instance.

@ProviderFor(orderStatusHistoryRepository)
final orderStatusHistoryRepositoryProvider =
    OrderStatusHistoryRepositoryProvider._();

/// Provides the OrderStatusHistoryRepository instance.

final class OrderStatusHistoryRepositoryProvider extends $FunctionalProvider<
    OrderStatusHistoryRepository,
    OrderStatusHistoryRepository,
    OrderStatusHistoryRepository> with $Provider<OrderStatusHistoryRepository> {
  /// Provides the OrderStatusHistoryRepository instance.
  OrderStatusHistoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderStatusHistoryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderStatusHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderStatusHistoryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderStatusHistoryRepository create(Ref ref) {
    return orderStatusHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderStatusHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderStatusHistoryRepository>(value),
    );
  }
}

String _$orderStatusHistoryRepositoryHash() =>
    r'7ebd6353a287835fe07a0862a88cbdf018848202';
