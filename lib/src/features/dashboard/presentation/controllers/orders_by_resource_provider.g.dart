// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_by_resource_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches sale service items filtered by date/branch and groups them
/// by machine or storage location.

@ProviderFor(ordersByResource)
final ordersByResourceProvider = OrdersByResourceFamily._();

/// Fetches sale service items filtered by date/branch and groups them
/// by machine or storage location.

final class OrdersByResourceProvider extends $FunctionalProvider<
        AsyncValue<OrdersByResourceData>,
        OrdersByResourceData,
        FutureOr<OrdersByResourceData>>
    with
        $FutureModifier<OrdersByResourceData>,
        $FutureProvider<OrdersByResourceData> {
  /// Fetches sale service items filtered by date/branch and groups them
  /// by machine or storage location.
  OrdersByResourceProvider._(
      {required OrdersByResourceFamily super.from,
      required OrdersByResourceFilter super.argument})
      : super(
          retry: null,
          name: r'ordersByResourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ordersByResourceHash();

  @override
  String toString() {
    return r'ordersByResourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrdersByResourceData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrdersByResourceData> create(Ref ref) {
    final argument = this.argument as OrdersByResourceFilter;
    return ordersByResource(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersByResourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersByResourceHash() => r'1a20a6757684b639da5b01947c00f3e555a941ab';

/// Fetches sale service items filtered by date/branch and groups them
/// by machine or storage location.

final class OrdersByResourceFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<OrdersByResourceData>,
            OrdersByResourceFilter> {
  OrdersByResourceFamily._()
      : super(
          retry: null,
          name: r'ordersByResourceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches sale service items filtered by date/branch and groups them
  /// by machine or storage location.

  OrdersByResourceProvider call(
    OrdersByResourceFilter filter,
  ) =>
      OrdersByResourceProvider._(argument: filter, from: this);

  @override
  String toString() => r'ordersByResourceProvider';
}
