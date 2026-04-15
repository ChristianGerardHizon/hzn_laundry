// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches aggregated payment summary from non-voided payment records.

@ProviderFor(paymentsSummary)
final paymentsSummaryProvider = PaymentsSummaryProvider._();

/// Fetches aggregated payment summary from non-voided payment records.

final class PaymentsSummaryProvider extends $FunctionalProvider<
        AsyncValue<List<PaymentsDailySummaryEntry>>,
        List<PaymentsDailySummaryEntry>,
        FutureOr<List<PaymentsDailySummaryEntry>>>
    with
        $FutureModifier<List<PaymentsDailySummaryEntry>>,
        $FutureProvider<List<PaymentsDailySummaryEntry>> {
  /// Fetches aggregated payment summary from non-voided payment records.
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

String _$paymentsSummaryHash() => r'dc7a975b9cab58a6797dae1c75248064708b1644';
