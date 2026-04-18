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

String _$notPickedUpCountHash() => r'a6e52067b77696a6b1d9edf41910856389869f97';

/// Count of backlog orders still in 'pending' status (not yet started).
/// Used to surface an at-a-glance warning on the Backlogs filter chip
/// regardless of which filter is currently active.

@ProviderFor(backlogPendingCount)
final backlogPendingCountProvider = BacklogPendingCountProvider._();

/// Count of backlog orders still in 'pending' status (not yet started).
/// Used to surface an at-a-glance warning on the Backlogs filter chip
/// regardless of which filter is currently active.

final class BacklogPendingCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of backlog orders still in 'pending' status (not yet started).
  /// Used to surface an at-a-glance warning on the Backlogs filter chip
  /// regardless of which filter is currently active.
  BacklogPendingCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backlogPendingCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backlogPendingCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return backlogPendingCount(ref);
  }
}

String _$backlogPendingCountHash() =>
    r'e7a03d0cb72bcfa9678e2fe46e85257501149a15';

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

String _$todayCountHash() => r'447fb6b9a0f6224785d7a2f2f70706908a88c249';

/// Counts orders in the opposite tab that match the given search query.
/// When on "Today's Orders", counts matching backlog orders, and vice versa.
/// Returns 0 when query is empty.

@ProviderFor(crossTabSearchCount)
final crossTabSearchCountProvider = CrossTabSearchCountFamily._();

/// Counts orders in the opposite tab that match the given search query.
/// When on "Today's Orders", counts matching backlog orders, and vice versa.
/// Returns 0 when query is empty.

final class CrossTabSearchCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Counts orders in the opposite tab that match the given search query.
  /// When on "Today's Orders", counts matching backlog orders, and vice versa.
  /// Returns 0 when query is empty.
  CrossTabSearchCountProvider._(
      {required CrossTabSearchCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'crossTabSearchCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crossTabSearchCountHash();

  @override
  String toString() {
    return r'crossTabSearchCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return crossTabSearchCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrossTabSearchCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crossTabSearchCountHash() =>
    r'9ba1255388209fe03785f5c4c61c085cd6409cc7';

/// Counts orders in the opposite tab that match the given search query.
/// When on "Today's Orders", counts matching backlog orders, and vice versa.
/// Returns 0 when query is empty.

final class CrossTabSearchCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  CrossTabSearchCountFamily._()
      : super(
          retry: null,
          name: r'crossTabSearchCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Counts orders in the opposite tab that match the given search query.
  /// When on "Today's Orders", counts matching backlog orders, and vice versa.
  /// Returns 0 when query is empty.

  CrossTabSearchCountProvider call(
    String query,
  ) =>
      CrossTabSearchCountProvider._(argument: query, from: this);

  @override
  String toString() => r'crossTabSearchCountProvider';
}

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

String _$kanbanSalesHash() => r'0817f12a3fc8fd834090a4b4a44512f23e4cc699';
