import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../reports/domain/payment_report_entry.dart';
import '../../../reports/domain/payments_summary.dart';
import '../../domain/payment.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_type.dart';
import '../dto/payment_dto.dart';

part 'payment_repository.g.dart';

abstract class PaymentRepository {
  /// Creates a new payment and updates the sale's isPaid status.
  FutureEither<Payment> create({
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
    DateTime? paymentDate,
  });

  /// Updates an existing payment and recalculates sale's isPaid status.
  FutureEither<Payment> update({
    required String id,
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
    DateTime? paymentDate,
  });

  /// Gets all payments for a sale.
  FutureEither<List<Payment>> getBySaleId(String saleId);

  /// Voids an existing payment and recalculates sale payment status.
  FutureEither<void> voidPayment({
    required String id,
    required String saleId,
    String? reason,
  });

  /// Gets all payments within a date range with sale context, optionally filtered by branch.
  FutureEither<List<PaymentReportEntry>> getForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  });

  /// Paginated payments within a date range with sale context.
  FutureEitherPaginated<PaymentReportEntry> getForDateRangePaginated({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
    String? searchQuery,
    List<String>? searchFields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  });

  /// Daily payment aggregates from [vw_payments_daily_summary] for [branchScope].
  ///
  /// Date-filters in Dart because view date fields are JSON (not PB-filterable).
  FutureEither<List<PaymentsDailySummaryEntry>> getDailySummaryForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  });

  /// Deletes a payment and updates the sale's isPaid status.
  FutureEither<void> delete(String id);

  /// Gets the total paid amount for a sale.
  FutureEither<num> getTotalPaidAmount(String saleId);
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepositoryImpl(ref.watch(pocketbaseProvider));
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PocketBase _pb;

  PaymentRepositoryImpl(this._pb);

  RecordService get _payments => _pb.collection(PocketBaseCollections.payments);
  RecordService get _sales => _pb.collection(PocketBaseCollections.sales);
  RecordService get _paymentsDailySummary =>
      _pb.collection(PocketBaseCollections.vwPaymentsDailySummary);

  Payment _toEntity(RecordModel record) {
    return PaymentDto.fromRecord(record).toEntity(baseUrl: _pb.baseURL);
  }

  @override
  FutureEither<Payment> create({
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
    DateTime? paymentDate,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Create payment record
        final body = <String, dynamic>{
          'sale': saleId,
          'amount': amount,
          'paymentMethod': paymentMethod.name,
          'type': type.name,
          'isVoided': false,
          'voidedAt': '',
          'voidReason': '',
          'paymentRef': paymentRef,
          'notes': notes,
        };

        body['postedDate'] = paymentDate != null
            ? paymentDate.toUtc().toIso8601String()
            : DateTime.now().toUtc().toIso8601String();

        final record = await _payments.create(
          body: body,
          files: paymentProofFile != null ? [paymentProofFile] : [],
        );

        // Update sale's isPaid status
        await _updateSaleIsPaid(saleId);

        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Payment> update({
    required String id,
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
    DateTime? paymentDate,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'amount': amount,
          'paymentMethod': paymentMethod.name,
          'type': type.name,
          'isVoided': false,
          'voidedAt': '',
          'voidReason': '',
          'paymentRef': paymentRef ?? '',
          'notes': notes ?? '',
        };

        if (paymentDate != null) {
          body['postedDate'] = paymentDate.toUtc().toIso8601String();
        }

        final record = await _payments.update(
          id,
          body: body,
          files: paymentProofFile != null ? [paymentProofFile] : [],
        );

        // Recalculate sale's isPaid status
        await _updateSaleIsPaid(saleId);

        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Payment>> getBySaleId(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _payments.getFullList(
          filter: 'sale = "$saleId"',
          sort: '-postedDate',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<PaymentReportEntry>> getForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notEquals('sale.status', 'voided')
            .isFalse('isVoided')
            .between('postedDate', startDate, endDate);

        final records = await _payments.getFullList(
          filter: PBFilters.combine(filter.build(), branchScope),
          sort: '-postedDate',
          expand: 'sale',
        );

        return records.map(_toReportEntry).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<PaymentReportEntry> getForDateRangePaginated({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
    String? searchQuery,
    List<String>? searchFields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final base = PBFilter()
            .notEquals('sale.status', 'voided')
            .isFalse('isVoided')
            .between('postedDate', startDate, endDate);

        String? filter = PBFilters.combine(base.build(), branchScope);

        final query = searchQuery?.trim();
        if (query != null && query.isNotEmpty && searchFields != null) {
          final pbFields = searchFields
              .map(_paymentSearchField)
              .whereType<String>()
              .toList();
          if (pbFields.isNotEmpty) {
            final searchFilter =
                PBFilter().searchFields(query, pbFields).build();
            filter = PBFilters.combine(filter, searchFilter);
          }
        }

        final result = await _payments.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-postedDate',
          expand: 'sale',
        );

        return PaginatedResult<PaymentReportEntry>(
          items: result.items.map(_toReportEntry).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<PaymentsDailySummaryEntry>> getDailySummaryForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _paymentsDailySummary.getFullList(
          filter: branchScope,
        );

        final startDay =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDay = DateTime(endDate.year, endDate.month, endDate.day);

        final entries = <PaymentsDailySummaryEntry>[];
        for (final record in records) {
          final dateStr =
              record.get<dynamic>('paymentDate')?.toString() ?? '';
          final parsed = DateTime.tryParse(dateStr);
          if (parsed == null) continue;

          final day = DateTime(parsed.year, parsed.month, parsed.day);
          if (day.isBefore(startDay) || day.isAfter(endDay)) continue;

          entries.add(PaymentsDailySummaryEntry(
            date: day,
            paymentMethod: _parsePaymentMethod(
              record.getStringValue('paymentMethod'),
            ),
            paymentType: _parsePaymentType(
              record.getStringValue('paymentType'),
            ),
            paymentCount: record.getIntValue('paymentCount'),
            totalAmount: _readNum(record, 'totalAmount'),
          ));
        }

        entries.sort((a, b) => b.date.compareTo(a.date));
        return entries;
      },
      Failure.handle,
    ).run();
  }

  PaymentReportEntry _toReportEntry(RecordModel record) {
    final payment = _toEntity(record);
    final saleExpanded = record.get<RecordModel?>('expand.sale');
    return PaymentReportEntry(
      payment: payment,
      saleId: payment.saleId,
      receiptNumber: saleExpanded?.getStringValue('receiptNumber') ?? '',
      customerName: saleExpanded?.getStringValue('customerName'),
      saleStatus: saleExpanded?.getStringValue('status') ?? '',
    );
  }

  String? _paymentSearchField(String key) => switch (key) {
        'customer' => 'sale.customerName',
        'receipt' => 'sale.receiptNumber',
        'amount' => 'amount',
        'reference' => 'paymentRef',
        'method' => 'paymentMethod',
        _ => null,
      };

  PaymentMethod _parsePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'gcash':
        return PaymentMethod.gcash;
      case 'card':
        return PaymentMethod.card;
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'check':
        return PaymentMethod.check;
      default:
        return PaymentMethod.cash;
    }
  }

  PaymentType _parsePaymentType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'payment':
        return PaymentType.payment;
      case 'deposit':
        return PaymentType.deposit;
      case 'refund':
        return PaymentType.refund;
      default:
        return PaymentType.payment;
    }
  }

  num _readNum(RecordModel record, String field) {
    final raw = record.get<dynamic>(field);
    if (raw is num) return raw;
    if (raw is String) return num.tryParse(raw) ?? 0;
    return record.getDoubleValue(field);
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        // Get payment first to know which sale to update
        final record = await _payments.getOne(id);
        final saleId = record.getStringValue('sale');

        // Delete the payment
        await _payments.delete(id);

        // Update sale's isPaid status
        await _updateSaleIsPaid(saleId);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> voidPayment({
    required String id,
    required String saleId,
    String? reason,
  }) async {
    return TaskEither.tryCatch(
      () async {
        await _payments.update(id, body: {
          'isVoided': true,
          'voidedAt': DateTime.now().toUtc().toIso8601String(),
          'voidReason': reason ?? '',
        });

        await _updateSaleIsPaid(saleId);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<num> getTotalPaidAmount(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        return await _calculateTotalPaid(saleId);
      },
      Failure.handle,
    ).run();
  }

  /// Calculates total paid amount for a sale, accounting for refunds.
  Future<num> _calculateTotalPaid(String saleId) async {
    final records = await _payments.getFullList(
      filter: 'sale = "$saleId" && isVoided = false',
    );

    num total = 0;
    for (final record in records) {
      if (record.getBoolValue('isVoided')) continue;
      final amount = record.getDoubleValue('amount');
      final type = record.getStringValue('type').toLowerCase();
      if (type == 'refund') {
        total -= amount;
      } else {
        total += amount;
      }
    }
    return total;
  }

  /// Updates sale.isPaid and paymentStatus based on total payments vs totalAmount.
  Future<void> _updateSaleIsPaid(String saleId) async {
    // Get sale to know total amount
    final sale = await _sales.getOne(saleId);
    final totalAmount = sale.getDoubleValue('totalAmount');

    // Calculate total paid
    final totalPaid = await _calculateTotalPaid(saleId);

    // Determine payment status
    final isPaid = totalPaid >= totalAmount;
    final String paymentStatus;
    if (totalPaid <= 0) {
      paymentStatus = 'unpaid';
    } else if (totalPaid < totalAmount) {
      paymentStatus = 'partial';
    } else {
      paymentStatus = 'paid';
    }

    await _sales.update(saleId, body: {
      'isPaid': isPaid,
      'paymentStatus': paymentStatus,
    });
  }
}
