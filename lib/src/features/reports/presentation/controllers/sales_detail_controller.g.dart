// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all sales within the selected date range for the Orders report tab.

@ProviderFor(salesDetail)
final salesDetailProvider = SalesDetailProvider._();

/// Fetches all sales within the selected date range for the Orders report tab.

final class SalesDetailProvider extends $FunctionalProvider<
        AsyncValue<List<Sale>>, List<Sale>, FutureOr<List<Sale>>>
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Fetches all sales within the selected date range for the Orders report tab.
  SalesDetailProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesDetailHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return salesDetail(ref);
  }
}

String _$salesDetailHash() => r'06981ddee79087ee5a2faf3dd24b834ad8311636';
