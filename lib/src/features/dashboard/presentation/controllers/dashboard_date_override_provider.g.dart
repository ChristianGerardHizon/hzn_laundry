// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_date_override_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the optional date override for the dashboard.
/// When null, the dashboard uses today's date.

@ProviderFor(DashboardDateOverride)
final dashboardDateOverrideProvider = DashboardDateOverrideProvider._();

/// Holds the optional date override for the dashboard.
/// When null, the dashboard uses today's date.
final class DashboardDateOverrideProvider
    extends $NotifierProvider<DashboardDateOverride, DateTime?> {
  /// Holds the optional date override for the dashboard.
  /// When null, the dashboard uses today's date.
  DashboardDateOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardDateOverrideProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardDateOverrideHash();

  @$internal
  @override
  DashboardDateOverride create() => DashboardDateOverride();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$dashboardDateOverrideHash() =>
    r'ea408f642656eb11e585433d98475592689c1ff8';

/// Holds the optional date override for the dashboard.
/// When null, the dashboard uses today's date.

abstract class _$DashboardDateOverride extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DateTime?, DateTime?>, DateTime?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Returns the effective date for dashboard queries.
/// Uses the override if set, otherwise falls back to today.

@ProviderFor(dashboardEffectiveDate)
final dashboardEffectiveDateProvider = DashboardEffectiveDateProvider._();

/// Returns the effective date for dashboard queries.
/// Uses the override if set, otherwise falls back to today.

final class DashboardEffectiveDateProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Returns the effective date for dashboard queries.
  /// Uses the override if set, otherwise falls back to today.
  DashboardEffectiveDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardEffectiveDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardEffectiveDateHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return dashboardEffectiveDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$dashboardEffectiveDateHash() =>
    r'454c3735ec7bd092062e2ab6e7ff371f2b41d18f';

/// Whether the dashboard date is overridden (not today).

@ProviderFor(isDashboardDateOverridden)
final isDashboardDateOverriddenProvider = IsDashboardDateOverriddenProvider._();

/// Whether the dashboard date is overridden (not today).

final class IsDashboardDateOverriddenProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether the dashboard date is overridden (not today).
  IsDashboardDateOverriddenProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isDashboardDateOverriddenProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isDashboardDateOverriddenHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isDashboardDateOverridden(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDashboardDateOverriddenHash() =>
    r'a4c6d44990ead7d4d8f5acfde0ab7ab5bafd7b08';
