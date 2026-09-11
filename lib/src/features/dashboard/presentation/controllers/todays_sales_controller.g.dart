// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_sales_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sales data for the effective dashboard date.
/// Filtered by the current branch / organization scope.

@ProviderFor(todaySales)
final todaySalesProvider = TodaySalesProvider._();

/// Sales data for the effective dashboard date.
/// Filtered by the current branch / organization scope.

final class TodaySalesProvider extends $FunctionalProvider<
        AsyncValue<List<Sale>>, List<Sale>, FutureOr<List<Sale>>>
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Sales data for the effective dashboard date.
  /// Filtered by the current branch / organization scope.
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

String _$todaySalesHash() => r'a5637339cf1c1d3cf23669e65f1be3a8312aa2bb';

/// Sales summary (count and total amount) for the effective dashboard date.
/// When viewing today, uses vw_todays_sales view for optimized query.
/// When viewing a different date, queries the sales collection directly.
/// Filtered by the current branch / organization scope.

@ProviderFor(todaySalesSummary)
final todaySalesSummaryProvider = TodaySalesSummaryProvider._();

/// Sales summary (count and total amount) for the effective dashboard date.
/// When viewing today, uses vw_todays_sales view for optimized query.
/// When viewing a different date, queries the sales collection directly.
/// Filtered by the current branch / organization scope.

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
  /// Filtered by the current branch / organization scope.
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

String _$todaySalesSummaryHash() => r'2ce5aa958d32235b5f1218594d88421434039488';
