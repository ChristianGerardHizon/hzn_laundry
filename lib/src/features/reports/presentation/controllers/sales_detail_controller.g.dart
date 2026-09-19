// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Paginated orders for the Orders report tab.

@ProviderFor(SalesDetailController)
final salesDetailControllerProvider = SalesDetailControllerProvider._();

/// Paginated orders for the Orders report tab.
final class SalesDetailControllerProvider extends $AsyncNotifierProvider<
    SalesDetailController, PaginatedState<Sale>> {
  /// Paginated orders for the Orders report tab.
  SalesDetailControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesDetailControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesDetailControllerHash();

  @$internal
  @override
  SalesDetailController create() => SalesDetailController();
}

String _$salesDetailControllerHash() =>
    r'010584196d50f742ca1a62c4374e56c76a743468';

/// Paginated orders for the Orders report tab.

abstract class _$SalesDetailController
    extends $AsyncNotifier<PaginatedState<Sale>> {
  FutureOr<PaginatedState<Sale>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<PaginatedState<Sale>>, PaginatedState<Sale>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PaginatedState<Sale>>, PaginatedState<Sale>>,
        AsyncValue<PaginatedState<Sale>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
