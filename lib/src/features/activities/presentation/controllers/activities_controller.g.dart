// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activities_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for a single activity tab with pagination and action filtering.
///
/// [collectionFilter] is the collection name to filter by, or empty string for all.

@ProviderFor(ActivitiesController)
final activitiesControllerProvider = ActivitiesControllerFamily._();

/// Controller for a single activity tab with pagination and action filtering.
///
/// [collectionFilter] is the collection name to filter by, or empty string for all.
final class ActivitiesControllerProvider
    extends $AsyncNotifierProvider<ActivitiesController, ActivitiesState> {
  /// Controller for a single activity tab with pagination and action filtering.
  ///
  /// [collectionFilter] is the collection name to filter by, or empty string for all.
  ActivitiesControllerProvider._(
      {required ActivitiesControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'activitiesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activitiesControllerHash();

  @override
  String toString() {
    return r'activitiesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActivitiesController create() => ActivitiesController();

  @override
  bool operator ==(Object other) {
    return other is ActivitiesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activitiesControllerHash() =>
    r'6f406664f25c90153d02a25d2c1c6009d4bccb33';

/// Controller for a single activity tab with pagination and action filtering.
///
/// [collectionFilter] is the collection name to filter by, or empty string for all.

final class ActivitiesControllerFamily extends $Family
    with
        $ClassFamilyOverride<ActivitiesController, AsyncValue<ActivitiesState>,
            ActivitiesState, FutureOr<ActivitiesState>, String> {
  ActivitiesControllerFamily._()
      : super(
          retry: null,
          name: r'activitiesControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for a single activity tab with pagination and action filtering.
  ///
  /// [collectionFilter] is the collection name to filter by, or empty string for all.

  ActivitiesControllerProvider call(
    String collectionFilter,
  ) =>
      ActivitiesControllerProvider._(argument: collectionFilter, from: this);

  @override
  String toString() => r'activitiesControllerProvider';
}

/// Controller for a single activity tab with pagination and action filtering.
///
/// [collectionFilter] is the collection name to filter by, or empty string for all.

abstract class _$ActivitiesController extends $AsyncNotifier<ActivitiesState> {
  late final _$args = ref.$arg as String;
  String get collectionFilter => _$args;

  FutureOr<ActivitiesState> build(
    String collectionFilter,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ActivitiesState>, ActivitiesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ActivitiesState>, ActivitiesState>,
        AsyncValue<ActivitiesState>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Provider for fetching activity logs for a specific record.

@ProviderFor(recordActivityLogs)
final recordActivityLogsProvider = RecordActivityLogsFamily._();

/// Provider for fetching activity logs for a specific record.

final class RecordActivityLogsProvider extends $FunctionalProvider<
        AsyncValue<List<ActivityLog>>,
        List<ActivityLog>,
        FutureOr<List<ActivityLog>>>
    with
        $FutureModifier<List<ActivityLog>>,
        $FutureProvider<List<ActivityLog>> {
  /// Provider for fetching activity logs for a specific record.
  RecordActivityLogsProvider._(
      {required RecordActivityLogsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recordActivityLogsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recordActivityLogsHash();

  @override
  String toString() {
    return r'recordActivityLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ActivityLog>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActivityLog>> create(Ref ref) {
    final argument = this.argument as String;
    return recordActivityLogs(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecordActivityLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recordActivityLogsHash() =>
    r'689a9795495ce004ccc89f945c69fc4513260e14';

/// Provider for fetching activity logs for a specific record.

final class RecordActivityLogsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ActivityLog>>, String> {
  RecordActivityLogsFamily._()
      : super(
          retry: null,
          name: r'recordActivityLogsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching activity logs for a specific record.

  RecordActivityLogsProvider call(
    String recordId,
  ) =>
      RecordActivityLogsProvider._(argument: recordId, from: this);

  @override
  String toString() => r'recordActivityLogsProvider';
}

/// Provider for fetching all activity logs related to a sale,
/// including logs for its payment records.

@ProviderFor(saleActivityLogs)
final saleActivityLogsProvider = SaleActivityLogsFamily._();

/// Provider for fetching all activity logs related to a sale,
/// including logs for its payment records.

final class SaleActivityLogsProvider extends $FunctionalProvider<
        AsyncValue<List<ActivityLog>>,
        List<ActivityLog>,
        FutureOr<List<ActivityLog>>>
    with
        $FutureModifier<List<ActivityLog>>,
        $FutureProvider<List<ActivityLog>> {
  /// Provider for fetching all activity logs related to a sale,
  /// including logs for its payment records.
  SaleActivityLogsProvider._(
      {required SaleActivityLogsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'saleActivityLogsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleActivityLogsHash();

  @override
  String toString() {
    return r'saleActivityLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ActivityLog>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActivityLog>> create(Ref ref) {
    final argument = this.argument as String;
    return saleActivityLogs(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleActivityLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleActivityLogsHash() => r'85439eb7fd436d07ec646c0a6496ef53e270f0f7';

/// Provider for fetching all activity logs related to a sale,
/// including logs for its payment records.

final class SaleActivityLogsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ActivityLog>>, String> {
  SaleActivityLogsFamily._()
      : super(
          retry: null,
          name: r'saleActivityLogsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching all activity logs related to a sale,
  /// including logs for its payment records.

  SaleActivityLogsProvider call(
    String saleId,
  ) =>
      SaleActivityLogsProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleActivityLogsProvider';
}
