import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/domain/payment_method.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payments_summary.dart';
import 'payments_date_range_controller.dart';

part 'payments_summary_controller.g.dart';

/// Fetches aggregated payment summary from [vw_payments_daily_summary].
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).
@riverpod
Future<List<PaymentsDailySummaryEntry>> paymentsSummary(Ref ref) async {
  final dateRange = ref.watch(paymentsDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final branchFilter =
      branchId != null ? 'branch = "$branchId"' : null;

  final records = await pb
      .collection(PocketBaseCollections.vwPaymentsDailySummary)
      .getFullList(filter: branchFilter);

  // Filter by date range in Dart
  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

  return records
      .map((record) {
        final dateStr =
            record.get<dynamic>('paymentDate')?.toString() ?? '';
        final date = DateTime.tryParse(dateStr);
        if (date == null) return null;

        if (date.isBefore(startDay) || date.isAfter(endDay)) return null;

        return PaymentsDailySummaryEntry(
          date: date,
          paymentMethod:
              _parseMethod(record.getStringValue('paymentMethod')),
          paymentType: _parseType(record.getStringValue('paymentType')),
          paymentCount: record.getIntValue('paymentCount'),
          totalAmount: record.getDoubleValue('totalAmount'),
        );
      })
      .whereType<PaymentsDailySummaryEntry>()
      .toList();
}

PaymentMethod _parseMethod(String m) => switch (m.toLowerCase()) {
      'cash' => PaymentMethod.cash,
      'card' => PaymentMethod.card,
      'banktransfer' => PaymentMethod.bankTransfer,
      'check' => PaymentMethod.check,
      _ => PaymentMethod.cash,
    };

PaymentType _parseType(String t) => switch (t.toLowerCase()) {
      'payment' => PaymentType.payment,
      'deposit' => PaymentType.deposit,
      'refund' => PaymentType.refund,
      _ => PaymentType.payment,
    };
