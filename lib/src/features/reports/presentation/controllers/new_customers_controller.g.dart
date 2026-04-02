// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all customers created within the selected date range.

@ProviderFor(newCustomersReport)
final newCustomersReportProvider = NewCustomersReportProvider._();

/// Fetches all customers created within the selected date range.

final class NewCustomersReportProvider extends $FunctionalProvider<
        AsyncValue<List<Customer>>, List<Customer>, FutureOr<List<Customer>>>
    with $FutureModifier<List<Customer>>, $FutureProvider<List<Customer>> {
  /// Fetches all customers created within the selected date range.
  NewCustomersReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'newCustomersReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newCustomersReportHash();

  @$internal
  @override
  $FutureProviderElement<List<Customer>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Customer>> create(Ref ref) {
    return newCustomersReport(ref);
  }
}

String _$newCustomersReportHash() =>
    r'e332056232c1def4e0b86f14616c6e08ff97a543';
