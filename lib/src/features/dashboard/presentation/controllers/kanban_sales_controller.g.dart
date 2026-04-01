// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_sales_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current kanban filter mode.

@ProviderFor(KanbanFilter)
final kanbanFilterProvider = KanbanFilterProvider._();

/// Holds the current kanban filter mode.
final class KanbanFilterProvider
    extends $NotifierProvider<KanbanFilter, KanbanFilterMode> {
  /// Holds the current kanban filter mode.
  KanbanFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kanbanFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kanbanFilterHash();

  @$internal
  @override
  KanbanFilter create() => KanbanFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KanbanFilterMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KanbanFilterMode>(value),
    );
  }
}

String _$kanbanFilterHash() => r'7537e62e3b892726c01857296d348c4106e18fcd';

/// Holds the current kanban filter mode.

abstract class _$KanbanFilter extends $Notifier<KanbanFilterMode> {
  KanbanFilterMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KanbanFilterMode, KanbanFilterMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<KanbanFilterMode, KanbanFilterMode>,
        KanbanFilterMode,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Count of orders not yet picked up (pending + processing + ready).
/// Used to display a badge on the "Not Picked Up" filter chip.

@ProviderFor(notPickedUpCount)
final notPickedUpCountProvider = NotPickedUpCountProvider._();

/// Count of orders not yet picked up (pending + processing + ready).
/// Used to display a badge on the "Not Picked Up" filter chip.

final class NotPickedUpCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of orders not yet picked up (pending + processing + ready).
  /// Used to display a badge on the "Not Picked Up" filter chip.
  NotPickedUpCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notPickedUpCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notPickedUpCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return notPickedUpCount(ref);
  }
}

String _$notPickedUpCountHash() => r'8604ad3fc9624135fd0a7d99831ae5f363f01b0b';

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today.
/// - [KanbanFilterMode.notPickedUp]: All orders not yet picked up (any date).
/// Filtered by current branch, sorted by most recent first.
/// Also fetches service items for processing/ready sales to display machine/storage.

@ProviderFor(kanbanSales)
final kanbanSalesProvider = KanbanSalesProvider._();

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today.
/// - [KanbanFilterMode.notPickedUp]: All orders not yet picked up (any date).
/// Filtered by current branch, sorted by most recent first.
/// Also fetches service items for processing/ready sales to display machine/storage.

final class KanbanSalesProvider extends $FunctionalProvider<
        AsyncValue<KanbanSalesData>, KanbanSalesData, FutureOr<KanbanSalesData>>
    with $FutureModifier<KanbanSalesData>, $FutureProvider<KanbanSalesData> {
  /// Fetches active sales grouped by order status based on the selected filter.
  /// - [KanbanFilterMode.today]: All orders created today.
  /// - [KanbanFilterMode.notPickedUp]: All orders not yet picked up (any date).
  /// Filtered by current branch, sorted by most recent first.
  /// Also fetches service items for processing/ready sales to display machine/storage.
  KanbanSalesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kanbanSalesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kanbanSalesHash();

  @$internal
  @override
  $FutureProviderElement<KanbanSalesData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KanbanSalesData> create(Ref ref) {
    return kanbanSales(ref);
  }
}

String _$kanbanSalesHash() => r'40eced4597b4fd092425e94608ad97cf6636e091';
