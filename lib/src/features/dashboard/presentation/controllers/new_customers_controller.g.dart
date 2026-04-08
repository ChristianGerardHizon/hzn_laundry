// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`.
/// Customers are global (no branch filter).

@ProviderFor(todaysNewCustomersCount)
final todaysNewCustomersCountProvider = TodaysNewCustomersCountProvider._();

/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`.
/// Customers are global (no branch filter).

final class TodaysNewCustomersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of new customers registered on the effective dashboard date.
  ///
  /// Queries the customers collection with a date filter on `created`.
  /// Customers are global (no branch filter).
  TodaysNewCustomersCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaysNewCustomersCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaysNewCustomersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todaysNewCustomersCount(ref);
  }
}

String _$todaysNewCustomersCountHash() =>
    r'2f2255c6eab581c792b3d05fba04770796dee236';
