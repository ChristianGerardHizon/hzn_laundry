import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/payment_repository.dart';
import '../../../pos/domain/payment_method.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payments_summary.dart';
import 'payments_date_range_controller.dart';

part 'payments_summary_controller.g.dart';

/// Fetches aggregated payment summary from non-voided payment records.
@riverpod
Future<List<PaymentsDailySummaryEntry>> paymentsSummary(Ref ref) async {
  final dateRange = ref.watch(paymentsDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(paymentRepositoryProvider);

  final result = await repository.getForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchId: branchId,
  );

  return result.fold(
    (failure) => throw failure,
    (entries) {
      final grouped = <({DateTime day, PaymentMethod method, PaymentType type}),
          PaymentsDailySummaryEntry>{};

      for (final entry in entries) {
        final postedDate = entry.payment.postedDate;
        if (postedDate == null) continue;

        final day = DateTime(postedDate.year, postedDate.month, postedDate.day);
        final key = (
          day: day,
          method: entry.payment.paymentMethod,
          type: entry.payment.type,
        );

        final existing = grouped[key];
        if (existing == null) {
          grouped[key] = PaymentsDailySummaryEntry(
            date: day,
            paymentMethod: entry.payment.paymentMethod,
            paymentType: entry.payment.type,
            paymentCount: 1,
            totalAmount: entry.payment.amount,
          );
          continue;
        }

        grouped[key] = PaymentsDailySummaryEntry(
          date: existing.date,
          paymentMethod: existing.paymentMethod,
          paymentType: existing.paymentType,
          paymentCount: existing.paymentCount + 1,
          totalAmount: existing.totalAmount + entry.payment.amount,
        );
      }

      return grouped.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    },
  );
}
