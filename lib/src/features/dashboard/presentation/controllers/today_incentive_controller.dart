import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sales_repository.dart';
import '../../../reports/domain/incentive_calculator.dart';
import '../../../settings/data/repositories/branch_repository.dart';
import '../../../settings/data/repositories/incentive_tier_repository.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/domain/incentive_tier.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_date_override_provider.dart';

part 'today_incentive_controller.g.dart';

/// Single order's incentive contribution shown on the dashboard modal.
class TodayOrderIncentiveEntry {
  const TodayOrderIncentiveEntry({
    required this.receiptNumber,
    required this.customerName,
    required this.servicePrice,
    required this.incentive,
    required this.orderStatus,
  });

  final String receiptNumber;
  final String? customerName;
  final num servicePrice;
  final num incentive;
  final String orderStatus;
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

  final dayStart = DateTime(
      effectiveDate.year, effectiveDate.month, effectiveDate.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final salesRepo = ref.read(salesRepositoryProvider);
  final tierRepo = ref.read(incentiveTierRepositoryProvider);
  final branchRepo = ref.read(branchRepositoryProvider);

  final salesResult = await salesRepo.getSaleServiceTotals(
    startDate: dayStart,
    endDate: dayEnd,
    branchId: branchId,
  );
  final saleRecords = salesResult.fold(
    (_) => <dynamic>[],
    (list) => list as List<dynamic>,
  );

  List<IncentiveTier> tiers = [];
  Branch? branch;
  if (branchId != null) {
    final tierResult = await tierRepo.fetchForBranch(branchId);
    tiers = tierResult.fold(
      (_) => <IncentiveTier>[],
      (list) => list,
    );
    final branchResult = await branchRepo.fetchOne(branchId);
    branch = branchResult.fold((_) => null, (b) => b);
  }

  final legacyRate = branch?.incentiveAmount ?? 5;
  final legacyPerServicePrice = branch?.incentivePerServiceItems ?? 200;

  final orders = <TodayOrderIncentiveEntry>[];
  num totalIncentive = 0;

  for (final record in saleRecords) {
    final orderStatus = record.getStringValue('orderStatus');
    if (orderStatus == 'processing') continue;

    final servicePrice =
        (record.data['serviceTotalAmount'] as num?) ?? 0;
    if (servicePrice <= 0) continue;

    final incentive =
        calculateIncentive(servicePrice, tiers, legacyRate, legacyPerServicePrice);
    totalIncentive += incentive;

    final receiptNumber = record.getStringValue('receiptNumber');
    final customerName = record.getStringValue('customerName');

    orders.add(TodayOrderIncentiveEntry(
      receiptNumber: receiptNumber,
      customerName: customerName.isEmpty ? null : customerName,
      servicePrice: servicePrice,
      incentive: incentive,
      orderStatus: orderStatus,
    ));
  }

  return TodayIncentiveSummary(
    totalIncentive: totalIncentive,
    orders: orders,
  );
}
