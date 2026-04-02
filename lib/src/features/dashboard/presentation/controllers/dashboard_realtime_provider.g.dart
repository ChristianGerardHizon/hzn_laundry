// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_realtime_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Subscribes to PocketBase realtime events for collections that affect the
/// dashboard, and invalidates the relevant providers when changes occur.
///
/// Uses PocketBase's built-in `PB_CONNECT` event to detect reconnections and
/// refresh all dashboard data, ensuring the UI stays in sync even after
/// network interruptions (common on web/mobile).
///
/// Usage: Simply `ref.watch(dashboardRealtimeProvider)` from the dashboard
/// page to activate subscriptions. They are automatically cleaned up when
/// the provider is disposed (i.e. when navigating away from the dashboard).

@ProviderFor(dashboardRealtime)
final dashboardRealtimeProvider = DashboardRealtimeProvider._();

/// Subscribes to PocketBase realtime events for collections that affect the
/// dashboard, and invalidates the relevant providers when changes occur.
///
/// Uses PocketBase's built-in `PB_CONNECT` event to detect reconnections and
/// refresh all dashboard data, ensuring the UI stays in sync even after
/// network interruptions (common on web/mobile).
///
/// Usage: Simply `ref.watch(dashboardRealtimeProvider)` from the dashboard
/// page to activate subscriptions. They are automatically cleaned up when
/// the provider is disposed (i.e. when navigating away from the dashboard).

final class DashboardRealtimeProvider
    extends $FunctionalProvider<void, void, void> with $Provider<void> {
  /// Subscribes to PocketBase realtime events for collections that affect the
  /// dashboard, and invalidates the relevant providers when changes occur.
  ///
  /// Uses PocketBase's built-in `PB_CONNECT` event to detect reconnections and
  /// refresh all dashboard data, ensuring the UI stays in sync even after
  /// network interruptions (common on web/mobile).
  ///
  /// Usage: Simply `ref.watch(dashboardRealtimeProvider)` from the dashboard
  /// page to activate subscriptions. They are automatically cleaned up when
  /// the provider is disposed (i.e. when navigating away from the dashboard).
  DashboardRealtimeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardRealtimeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardRealtimeHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return dashboardRealtime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$dashboardRealtimeHash() => r'187ccb5c2c49f97ba769919bcc9c67544d530623';
