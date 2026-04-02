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

/// Count of backlog orders (not yet picked up, created before today).
/// Used to display a badge on the "Backlogs" filter chip.

@ProviderFor(notPickedUpCount)
final notPickedUpCountProvider = NotPickedUpCountProvider._();

/// Count of backlog orders (not yet picked up, created before today).
/// Used to display a badge on the "Backlogs" filter chip.

final class NotPickedUpCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of backlog orders (not yet picked up, created before today).
  /// Used to display a badge on the "Backlogs" filter chip.
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

String _$notPickedUpCountHash() => r'a17d37fb104cbdfbeb9c5677f9d3363aee6b16f0';

/// Count of orders created today.
/// Used to display a badge on the "Today's Orders" filter chip.

@ProviderFor(todayCount)
final todayCountProvider = TodayCountProvider._();

/// Count of orders created today.
/// Used to display a badge on the "Today's Orders" filter chip.

final class TodayCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of orders created today.
  /// Used to display a badge on the "Today's Orders" filter chip.
  TodayCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todayCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todayCount(ref);
  }
}

String _$todayCountHash() => r'c203317df4f8d33a98517af5e26e43e2531c80bf';

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today (any status).
/// - [KanbanFilterMode.notPickedUp]: Orders created before today that haven't been picked up.
/// The two filters are mutually exclusive — no order appears in both.
/// Filtered by current branch, sorted by most recent first.
/// Also fetches service items for processing/ready sales to display machine/storage.

@ProviderFor(kanbanSales)
final kanbanSalesProvider = KanbanSalesProvider._();

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today (any status).
/// - [KanbanFilterMode.notPickedUp]: Orders created before today that haven't been picked up.
/// The two filters are mutually exclusive — no order appears in both.
/// Filtered by current branch, sorted by most recent first.
/// Also fetches service items for processing/ready sales to display machine/storage.

final class KanbanSalesProvider extends $FunctionalProvider<
        AsyncValue<KanbanSalesData>, KanbanSalesData, FutureOr<KanbanSalesData>>
    with $FutureModifier<KanbanSalesData>, $FutureProvider<KanbanSalesData> {
  /// Fetches active sales grouped by order status based on the selected filter.
  /// - [KanbanFilterMode.today]: All orders created today (any status).
  /// - [KanbanFilterMode.notPickedUp]: Orders created before today that haven't been picked up.
  /// The two filters are mutually exclusive — no order appears in both.
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

String _$kanbanSalesHash() => r'a2d674f0e1a949cde9151747b90838eaeeb011aa';
