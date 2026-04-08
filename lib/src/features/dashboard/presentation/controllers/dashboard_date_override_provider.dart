import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_date_override_provider.g.dart';

/// Holds the optional date override for the dashboard.
/// When null, the dashboard uses today's date.
@Riverpod(keepAlive: true)
class DashboardDateOverride extends _$DashboardDateOverride {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) {
    state = date;
  }

  void clearOverride() {
    state = null;
  }
}

/// Returns the effective date for dashboard queries.
/// Uses the override if set, otherwise falls back to today.
@riverpod
DateTime dashboardEffectiveDate(Ref ref) {
  final override = ref.watch(dashboardDateOverrideProvider);
  return override ?? DateTime.now();
}

/// Whether the dashboard date is overridden (not today).
@riverpod
bool isDashboardDateOverridden(Ref ref) {
  return ref.watch(dashboardDateOverrideProvider) != null;
}
