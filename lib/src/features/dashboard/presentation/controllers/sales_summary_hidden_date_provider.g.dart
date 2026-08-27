// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_hidden_date_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device-local date the dashboard sales summary was collapsed.
///
/// When the stored value equals today's local date, the section stays hidden
/// until it is expanded again or the calendar day changes.

@ProviderFor(SalesSummaryHiddenDate)
final salesSummaryHiddenDateProvider = SalesSummaryHiddenDateProvider._();

/// Device-local date the dashboard sales summary was collapsed.
///
/// When the stored value equals today's local date, the section stays hidden
/// until it is expanded again or the calendar day changes.
final class SalesSummaryHiddenDateProvider
    extends $AsyncNotifierProvider<SalesSummaryHiddenDate, String?> {
  /// Device-local date the dashboard sales summary was collapsed.
  ///
  /// When the stored value equals today's local date, the section stays hidden
  /// until it is expanded again or the calendar day changes.
  SalesSummaryHiddenDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesSummaryHiddenDateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesSummaryHiddenDateHash();

  @$internal
  @override
  SalesSummaryHiddenDate create() => SalesSummaryHiddenDate();
}

String _$salesSummaryHiddenDateHash() =>
    r'89bbe6f1de3ac90a91d876caa96ec0c5b18a05fe';

/// Device-local date the dashboard sales summary was collapsed.
///
/// When the stored value equals today's local date, the section stays hidden
/// until it is expanded again or the calendar day changes.

abstract class _$SalesSummaryHiddenDate extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String?>, String?>,
        AsyncValue<String?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
