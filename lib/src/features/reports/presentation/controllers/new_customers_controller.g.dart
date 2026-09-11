// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches customers created within the selected date range,
/// scoped to the current branch / organization.

@ProviderFor(newCustomersReport)
final newCustomersReportProvider = NewCustomersReportProvider._();

/// Fetches customers created within the selected date range,
/// scoped to the current branch / organization.

final class NewCustomersReportProvider extends $FunctionalProvider<
        AsyncValue<List<Customer>>, List<Customer>, FutureOr<List<Customer>>>
    with $FutureModifier<List<Customer>>, $FutureProvider<List<Customer>> {
  /// Fetches customers created within the selected date range,
  /// scoped to the current branch / organization.
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
    r'341e71b01911f05c3d2c8716bdd714580abe575c';
