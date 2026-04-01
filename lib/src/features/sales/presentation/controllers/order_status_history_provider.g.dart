// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_status_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching status history entries for a sale.

@ProviderFor(orderStatusHistory)
final orderStatusHistoryProvider = OrderStatusHistoryFamily._();

/// Provider for fetching status history entries for a sale.

final class OrderStatusHistoryProvider extends $FunctionalProvider<
        AsyncValue<List<OrderStatusHistory>>,
        List<OrderStatusHistory>,
        FutureOr<List<OrderStatusHistory>>>
    with
        $FutureModifier<List<OrderStatusHistory>>,
        $FutureProvider<List<OrderStatusHistory>> {
  /// Provider for fetching status history entries for a sale.
  OrderStatusHistoryProvider._(
      {required OrderStatusHistoryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'orderStatusHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderStatusHistoryHash();

  @override
  String toString() {
    return r'orderStatusHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OrderStatusHistory>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderStatusHistory>> create(Ref ref) {
    final argument = this.argument as String;
    return orderStatusHistory(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderStatusHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderStatusHistoryHash() =>
    r'c985c66172dddd79bdc7c11a307ea8d60ff84e6b';

/// Provider for fetching status history entries for a sale.

final class OrderStatusHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OrderStatusHistory>>, String> {
  OrderStatusHistoryFamily._()
      : super(
          retry: null,
          name: r'orderStatusHistoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching status history entries for a sale.

  OrderStatusHistoryProvider call(
    String saleId,
  ) =>
      OrderStatusHistoryProvider._(argument: saleId, from: this);

  @override
  String toString() => r'orderStatusHistoryProvider';
}
