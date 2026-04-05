// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ActivityLogRepository instance.

@ProviderFor(activityLogRepository)
final activityLogRepositoryProvider = ActivityLogRepositoryProvider._();

/// Provides the ActivityLogRepository instance.

final class ActivityLogRepositoryProvider extends $FunctionalProvider<
    ActivityLogRepository,
    ActivityLogRepository,
    ActivityLogRepository> with $Provider<ActivityLogRepository> {
  /// Provides the ActivityLogRepository instance.
  ActivityLogRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activityLogRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activityLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActivityLogRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActivityLogRepository create(Ref ref) {
    return activityLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityLogRepository>(value),
    );
  }
}

String _$activityLogRepositoryHash() =>
    r'ca948a01dd9fd27ec5175c8c208344aafb1597ea';
