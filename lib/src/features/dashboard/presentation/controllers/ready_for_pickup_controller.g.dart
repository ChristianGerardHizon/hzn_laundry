// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_for_pickup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all sales with orderStatus = 'ready' for the current branch.
/// Sorted by most recent first.

@ProviderFor(readyForPickupSales)
final readyForPickupSalesProvider = ReadyForPickupSalesProvider._();

/// Fetches all sales with orderStatus = 'ready' for the current branch.
/// Sorted by most recent first.

final class ReadyForPickupSalesProvider extends $FunctionalProvider<
        AsyncValue<List<Sale>>, List<Sale>, FutureOr<List<Sale>>>
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Fetches all sales with orderStatus = 'ready' for the current branch.
  /// Sorted by most recent first.
  ReadyForPickupSalesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'readyForPickupSalesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readyForPickupSalesHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return readyForPickupSales(ref);
  }
}

String _$readyForPickupSalesHash() =>
    r'6c32b53214fe8d0c995557b04b4b93284de46302';

/// Summary of ready-for-pickup sales with paid/unpaid counts.

@ProviderFor(readyForPickupSummary)
final readyForPickupSummaryProvider = ReadyForPickupSummaryProvider._();

/// Summary of ready-for-pickup sales with paid/unpaid counts.

final class ReadyForPickupSummaryProvider extends $FunctionalProvider<
        AsyncValue<ReadyForPickupSummary>,
        ReadyForPickupSummary,
        FutureOr<ReadyForPickupSummary>>
    with
        $FutureModifier<ReadyForPickupSummary>,
        $FutureProvider<ReadyForPickupSummary> {
  /// Summary of ready-for-pickup sales with paid/unpaid counts.
  ReadyForPickupSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'readyForPickupSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readyForPickupSummaryHash();

  @$internal
  @override
  $FutureProviderElement<ReadyForPickupSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ReadyForPickupSummary> create(Ref ref) {
    return readyForPickupSummary(ref);
  }
}

String _$readyForPickupSummaryHash() =>
    r'96d29c8b9ab98ebaa5b75cd1ee4274a7ffc1a737';
