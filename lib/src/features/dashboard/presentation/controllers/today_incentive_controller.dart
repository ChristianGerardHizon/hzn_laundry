import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fpdart/fpdart.dart';

import '../../../pos/data/repositories/sales_repository.dart';
import '../../../reports/domain/incentive_calculator.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/domain/incentive_tier.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/incentive_tiers_provider.dart';
import 'dashboard_date_override_provider.dart';

part 'today_incentive_controller.g.dart';

DateTime? _parseRecordDate(dynamic rawValue) {
  if (rawValue is DateTime) return rawValue.toLocal();
  if (rawValue is String && rawValue.isNotEmpty) {
    return DateTime.tryParse(rawValue)?.toLocal();
  }
  return null;
}

/// Single order's incentive contribution shown on the dashboard modal.
class TodayOrderIncentiveEntry {
  const TodayOrderIncentiveEntry({
    required this.receiptNumber,
    required this.customerName,
    required this.servicePrice,
    required this.incentive,
    required this.orderStatus,
    required this.isBacklog,
  });

  final String receiptNumber;
  final String? customerName;
  final num servicePrice;
  final num incentive;
  final String orderStatus;
  final bool isBacklog;
}

/// Summary of today's incentive pool shown on the dashboard KPI.
class TodayIncentiveSummary {
  const TodayIncentiveSummary({
    required this.totalIncentive,
    required this.orders,
  });

  final num totalIncentive;
  final List<TodayOrderIncentiveEntry> orders;

  static const empty = TodayIncentiveSummary(totalIncentive: 0, orders: []);
}

/// Provider that calculates the total incentive for the effective dashboard date.
///
/// Excludes orders with status 'processing'.
@riverpod
Future<TodayIncentiveSummary> todayIncentiveSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final effectiveDate = ref.watch(dashboardEffectiveDateProvider);

  final dayStart =
      DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final salesRepo = ref.read(salesRepositoryProvider);

  // Fetch sales rows, branch, and tiers in parallel. Branch + tiers are
  // served from keepAlive caches so subsequent dashboard rebuilds (e.g. on
  // date changes) only re-hit the sales view.
  final results = await Future.wait([
    salesRepo.getTodayIncentiveRows(
      startDate: dayStart,
      endDate: dayEnd,
      branchId: branchId,
    ),
    if (branchId != null) ref.watch(branchProvider(branchId).future),
    if (branchId != null)
      ref.watch(incentiveTiersForBranchProvider(branchId).future),
  ]);

  final saleRecords = (results[0] as Either).fold(
    (_) => <dynamic>[],
    (list) => list as List<dynamic>,
  );
  final Branch? branch = branchId != null ? results[1] as Branch? : null;
  final List<IncentiveTier> tiers = branchId != null
      ? results[2] as List<IncentiveTier>
      : const <IncentiveTier>[];

  final legacyRate = branch?.incentiveAmount ?? 5;
  final legacyPerServicePrice = branch?.incentivePerServiceItems ?? 200;

  final orders = <TodayOrderIncentiveEntry>[];
  num totalIncentive = 0;

  for (final record in saleRecords) {
    final orderStatus = record.getStringValue('orderStatus');
    if (orderStatus == 'processing') continue;

    final servicePrice = (record.data['serviceTotalAmount'] as num?) ?? 0;
    if (servicePrice <= 0) continue;

    final incentive = calculateIncentive(
        servicePrice, tiers, legacyRate, legacyPerServicePrice);
    totalIncentive += incentive;

    final receiptNumber = record.getStringValue('receiptNumber');
    final customerName = record.getStringValue('customerName');
    final effectivePostedDate =
        _parseRecordDate(record.data['effectivePostedDate']) ??
            _parseRecordDate(record.data['postedDate']) ??
            _parseRecordDate(record.data['created']);
    final isBacklog = effectivePostedDate == null ||
        effectivePostedDate.isBefore(dayStart) ||
        !effectivePostedDate.isBefore(dayEnd);

    orders.add(TodayOrderIncentiveEntry(
      receiptNumber: receiptNumber,
      customerName: customerName.isEmpty ? null : customerName,
      servicePrice: servicePrice,
      incentive: incentive,
      orderStatus: orderStatus,
      isBacklog: isBacklog,
    ));
  }

  return TodayIncentiveSummary(
    totalIncentive: totalIncentive,
    orders: orders,
  );
}
