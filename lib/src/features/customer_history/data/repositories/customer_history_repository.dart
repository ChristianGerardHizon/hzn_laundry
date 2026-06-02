import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/payment_status.dart';
import '../../domain/customer_history.dart';

part 'customer_history_repository.g.dart';

abstract class CustomerHistoryRepository {
  FutureEither<CustomerHistory> fetchByToken(String token);
  FutureEither<CustomerHistorySaleDetail> fetchSaleDetail(String token, String saleId);
}

@Riverpod(keepAlive: true)
CustomerHistoryRepository customerHistoryRepository(Ref ref) {
  return CustomerHistoryRepositoryImpl(baseUrl: pocketbaseUrl);
}

class CustomerHistoryRepositoryImpl implements CustomerHistoryRepository {
  CustomerHistoryRepositoryImpl({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  FutureEither<CustomerHistory> fetchByToken(String token) async {
    return TaskEither.tryCatch(
      () async {
        final uri = Uri.parse('$baseUrl/api/customer-history/$token');
        final res = await _client.get(uri);

        if (res.statusCode == 404) {
          throw const DataFailure(
            'Link not found',
            null,
            'history_not_found',
          );
        }
        if (res.statusCode == 410) {
          throw const DataFailure(
            'Link expired',
            null,
            'history_expired',
          );
        }
        if (res.statusCode != 200) {
          throw DataFailure(
            'Failed to load history (${res.statusCode})',
            null,
            'history_load_failed',
          );
        }

        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          throw const DataFailure(
            'Unable to load history',
            null,
            'history_load_failed',
          );
        }

        final c = body['customer'] as Map<String, dynamic>;
        final customer = CustomerHistoryCustomer(
          id: c['id'] as String,
          name: (c['name'] as String?) ?? 'Customer',
          phone: c['phone'] as String?,
        );

        final salesJson = (body['sales'] as List? ?? []).cast<Map<String, dynamic>>();
        final sales = salesJson.map(_parseSale).toList();

        return CustomerHistory(customer: customer, sales: sales);
      },
      Failure.handle,
    ).run();
  }

  CustomerHistorySale _parseSale(Map<String, dynamic> j) {
    return CustomerHistorySale(
      id: j['id'] as String,
      receiptNumber: (j['receiptNumber'] as String?) ?? '',
      totalAmount: (j['totalAmount'] as num?) ?? 0,
      orderStatus: _parseOrderStatus(j['orderStatus'] as String?),
      paymentStatus: _parsePaymentStatus(j['paymentStatus'] as String?),
      isPaid: (j['isPaid'] as bool?) ?? false,
      packs: ((j['packs'] as num?) ?? 0).toInt(),
      notes: (j['notes'] as String?)?.isNotEmpty == true ? j['notes'] as String : null,
      pickedUpAt: _parseDate(j['pickedUpAt']),
      postedDate: _parseDate(j['postedDate']),
      created: _parseDate(j['created']),
    );
  }

  @override
  FutureEither<CustomerHistorySaleDetail> fetchSaleDetail(
    String token,
    String saleId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final uri = Uri.parse('$baseUrl/api/customer-history/$token/sales/$saleId');
        final res = await _client.get(uri);

        if (res.statusCode == 404) {
          throw const DataFailure('Order not found', null, 'order_not_found');
        }
        if (res.statusCode == 410) {
          throw const DataFailure('Link expired', null, 'history_expired');
        }
        if (res.statusCode != 200) {
          throw DataFailure(
            'Failed to load order (${res.statusCode})',
            null,
            'order_load_failed',
          );
        }

        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          throw const DataFailure('Unable to load order', null, 'order_load_failed');
        }

        final c = body['customer'] as Map<String, dynamic>;
        final customer = CustomerHistoryCustomer(
          id: c['id'] as String,
          name: (c['name'] as String?) ?? 'Customer',
          phone: c['phone'] as String?,
        );

        final sale = _parseSale(body['sale'] as Map<String, dynamic>);

        final items = ((body['items'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((j) => CustomerHistoryItem(
                  id: j['id'] as String,
                  productName: (j['productName'] as String?) ?? '',
                  quantity: (j['quantity'] as num?) ?? 0,
                  unitPrice: (j['unitPrice'] as num?) ?? 0,
                  subtotal: (j['subtotal'] as num?) ?? 0,
                ))
            .toList();

        final services = ((body['services'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((j) => CustomerHistoryServiceItem(
                  id: j['id'] as String,
                  serviceName: (j['serviceName'] as String?) ?? '',
                  quantity: (j['quantity'] as num?) ?? 0,
                  unitPrice: (j['unitPrice'] as num?) ?? 0,
                  subtotal: (j['subtotal'] as num?) ?? 0,
                  status: (j['status'] as String?)?.isNotEmpty == true ? j['status'] as String : null,
                  machineName: (j['machineName'] as String?)?.isNotEmpty == true ? j['machineName'] as String : null,
                  storageName: (j['storageName'] as String?)?.isNotEmpty == true ? j['storageName'] as String : null,
                ))
            .toList();

        return CustomerHistorySaleDetail(
          customer: customer,
          sale: sale,
          items: items,
          services: services,
        );
      },
      Failure.handle,
    ).run();
  }

  OrderStatus _parseOrderStatus(String? v) {
    switch (v) {
      case 'processing':
        return OrderStatus.processing;
      case 'ready':
        return OrderStatus.ready;
      case 'pickedUp':
        return OrderStatus.pickedUp;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  PaymentStatus _parsePaymentStatus(String? v) {
    switch (v) {
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      case 'unpaid':
      default:
        return PaymentStatus.unpaid;
    }
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s.contains('T') ? s : s.replaceFirst(' ', 'T')).toLocal();
    } catch (e) {
      if (kDebugMode) debugPrint('Date parse failed: $s');
      return null;
    }
  }
}
