// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all payments within the selected date range with sale context.

@ProviderFor(paymentsReport)
final paymentsReportProvider = PaymentsReportProvider._();

/// Fetches all payments within the selected date range with sale context.

final class PaymentsReportProvider extends $FunctionalProvider<
        AsyncValue<List<PaymentReportEntry>>,
        List<PaymentReportEntry>,
        FutureOr<List<PaymentReportEntry>>>
    with
        $FutureModifier<List<PaymentReportEntry>>,
        $FutureProvider<List<PaymentReportEntry>> {
  /// Fetches all payments within the selected date range with sale context.
  PaymentsReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentsReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentsReportHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentReportEntry>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentReportEntry>> create(Ref ref) {
    return paymentsReport(ref);
  }
}

String _$paymentsReportHash() => r'ed91d6c5df5e81013fdaa3bb68cbaaf000fc7cb1';
