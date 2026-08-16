// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`,
/// scoped to the current branch when one is selected.

@ProviderFor(todaysNewCustomersCount)
final todaysNewCustomersCountProvider = TodaysNewCustomersCountProvider._();

/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`,
/// scoped to the current branch when one is selected.

final class TodaysNewCustomersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of new customers registered on the effective dashboard date.
  ///
  /// Queries the customers collection with a date filter on `created`,
  /// scoped to the current branch when one is selected.
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
    r'7e15097e522dbc4064416ff348742f9b639d2e19';
