// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single activity log by ID.

@ProviderFor(activityLog)
final activityLogProvider = ActivityLogFamily._();

/// Provider for a single activity log by ID.

final class ActivityLogProvider extends $FunctionalProvider<
        AsyncValue<ActivityLog?>, ActivityLog?, FutureOr<ActivityLog?>>
    with $FutureModifier<ActivityLog?>, $FutureProvider<ActivityLog?> {
  /// Provider for a single activity log by ID.
  ActivityLogProvider._(
      {required ActivityLogFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'activityLogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activityLogHash();

  @override
  String toString() {
    return r'activityLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ActivityLog?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ActivityLog?> create(Ref ref) {
    final argument = this.argument as String;
    return activityLog(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityLogHash() => r'9504a243071d5a58d722f8cbe8bb29edcdf4d244';

/// Provider for a single activity log by ID.

final class ActivityLogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ActivityLog?>, String> {
  ActivityLogFamily._()
      : super(
          retry: null,
          name: r'activityLogProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single activity log by ID.

  ActivityLogProvider call(
    String id,
  ) =>
      ActivityLogProvider._(argument: id, from: this);

  @override
  String toString() => r'activityLogProvider';
}
