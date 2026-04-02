// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches aggregated payment summary from [vw_payments_daily_summary].
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).

@ProviderFor(paymentsSummary)
final paymentsSummaryProvider = PaymentsSummaryProvider._();

/// Fetches aggregated payment summary from [vw_payments_daily_summary].
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).

final class PaymentsSummaryProvider extends $FunctionalProvider<
        AsyncValue<List<PaymentsDailySummaryEntry>>,
        List<PaymentsDailySummaryEntry>,
        FutureOr<List<PaymentsDailySummaryEntry>>>
    with
        $FutureModifier<List<PaymentsDailySummaryEntry>>,
        $FutureProvider<List<PaymentsDailySummaryEntry>> {
  /// Fetches aggregated payment summary from [vw_payments_daily_summary].
  ///
  /// Uses branch filter on the query, then filters by date range in Dart
  /// (view date fields are JSON type, not filterable via PB date operators).
  PaymentsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentsSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentsDailySummaryEntry>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentsDailySummaryEntry>> create(Ref ref) {
    return paymentsSummary(ref);
  }
}

String _$paymentsSummaryHash() => r'01ef77b4ed054d83f5a437145e53f69416708dae';
