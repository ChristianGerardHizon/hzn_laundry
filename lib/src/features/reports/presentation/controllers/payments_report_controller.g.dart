// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Paginated payments within the selected report date range.

@ProviderFor(PaymentsReportController)
final paymentsReportControllerProvider = PaymentsReportControllerProvider._();

/// Paginated payments within the selected report date range.
final class PaymentsReportControllerProvider extends $AsyncNotifierProvider<
    PaymentsReportController, PaginatedState<PaymentReportEntry>> {
  /// Paginated payments within the selected report date range.
  PaymentsReportControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentsReportControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentsReportControllerHash();

  @$internal
  @override
  PaymentsReportController create() => PaymentsReportController();
}

String _$paymentsReportControllerHash() =>
    r'c758c5f786872235ceda842e255eb39250d71312';

/// Paginated payments within the selected report date range.

abstract class _$PaymentsReportController
    extends $AsyncNotifier<PaginatedState<PaymentReportEntry>> {
  FutureOr<PaginatedState<PaymentReportEntry>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PaginatedState<PaymentReportEntry>>,
        PaginatedState<PaymentReportEntry>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PaginatedState<PaymentReportEntry>>,
            PaginatedState<PaymentReportEntry>>,
        AsyncValue<PaginatedState<PaymentReportEntry>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
