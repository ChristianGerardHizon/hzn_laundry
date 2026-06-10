// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_sales_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sales data for the effective dashboard date.
/// Filtered by the current branch.

@ProviderFor(todaySales)
final todaySalesProvider = TodaySalesProvider._();

/// Sales data for the effective dashboard date.
/// Filtered by the current branch.

final class TodaySalesProvider extends $FunctionalProvider<
        AsyncValue<List<Sale>>, List<Sale>, FutureOr<List<Sale>>>
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Sales data for the effective dashboard date.
  /// Filtered by the current branch.
  TodaySalesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaySalesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaySalesHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return todaySales(ref);
  }
}

String _$todaySalesHash() => r'5907e8976c7cfa193dbd4b8c78be6c720983e923';

/// Sales summary (count and total amount) for the effective dashboard date.
/// When viewing today, uses vw_todays_sales view for optimized query.
/// When viewing a different date, queries the sales collection directly.
/// Filtered by the current branch.

@ProviderFor(todaySalesSummary)
final todaySalesSummaryProvider = TodaySalesSummaryProvider._();

/// Sales summary (count and total amount) for the effective dashboard date.
/// When viewing today, uses vw_todays_sales view for optimized query.
/// When viewing a different date, queries the sales collection directly.
/// Filtered by the current branch.

final class TodaySalesSummaryProvider extends $FunctionalProvider<
        AsyncValue<TodaySalesSummary>,
        TodaySalesSummary,
        FutureOr<TodaySalesSummary>>
    with
        $FutureModifier<TodaySalesSummary>,
        $FutureProvider<TodaySalesSummary> {
  /// Sales summary (count and total amount) for the effective dashboard date.
  /// When viewing today, uses vw_todays_sales view for optimized query.
  /// When viewing a different date, queries the sales collection directly.
  /// Filtered by the current branch.
  TodaySalesSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaySalesSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaySalesSummaryHash();

  @$internal
  @override
  $FutureProviderElement<TodaySalesSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TodaySalesSummary> create(Ref ref) {
    return todaySalesSummary(ref);
  }
}

String _$todaySalesSummaryHash() => r'49f40997da13f3161b8412cad4334e9575c432b2';
