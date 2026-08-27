// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incomplete_orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Open processing orders plus Ready / same-day Picked Up orders missing
/// machines or packs.

@ProviderFor(incompleteOrders)
final incompleteOrdersProvider = IncompleteOrdersProvider._();

/// Open processing orders plus Ready / same-day Picked Up orders missing
/// machines or packs.

final class IncompleteOrdersProvider extends $FunctionalProvider<
        AsyncValue<IncompleteOrdersData>,
        IncompleteOrdersData,
        FutureOr<IncompleteOrdersData>>
    with
        $FutureModifier<IncompleteOrdersData>,
        $FutureProvider<IncompleteOrdersData> {
  /// Open processing orders plus Ready / same-day Picked Up orders missing
  /// machines or packs.
  IncompleteOrdersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'incompleteOrdersProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$incompleteOrdersHash();

  @$internal
  @override
  $FutureProviderElement<IncompleteOrdersData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IncompleteOrdersData> create(Ref ref) {
    return incompleteOrders(ref);
  }
}

String _$incompleteOrdersHash() => r'incompleteOrdersManual001';
