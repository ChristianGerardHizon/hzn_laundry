import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../reports/domain/payment_report_entry.dart';
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
    String? branchId,
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
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notEquals('sale.status', 'voided')
            .isFalse('isVoided')
            .between('postedDate', startDate, endDate);
        if (branchId != null) {
          filter.relation('sale.branch', branchId);
        }

        final records = await _payments.getFullList(
          filter: filter.build(),
          sort: '-postedDate',
          expand: 'sale',
        );

        return records.map((record) {
          final payment = _toEntity(record);
          final saleExpanded = record.get<RecordModel?>('expand.sale');
          return PaymentReportEntry(
            payment: payment,
            saleId: payment.saleId,
            receiptNumber: saleExpanded?.getStringValue('receiptNumber') ?? '',
            customerName: saleExpanded?.getStringValue('customerName'),
            saleStatus: saleExpanded?.getStringValue('status') ?? '',
          );
        }).toList();
      },
      Failure.handle,
    ).run();
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
