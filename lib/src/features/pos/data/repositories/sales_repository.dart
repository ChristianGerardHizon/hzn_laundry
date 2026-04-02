import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../domain/order_status.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';
import '../dto/order_status_history_dto.dart';
import '../dto/sale_dto.dart';
import '../dto/sale_item_dto.dart';

part 'sales_repository.g.dart';

abstract class SalesRepository {
  FutureEither<Sale> createSale(
    Sale sale,
    List<SaleItem> items, {
    List<SaleServiceItem> serviceItems,
  });
  FutureEither<Sale> getSale(String id);
  FutureEither<List<Sale>> getSales({String? branchId, DateTime? date});
  FutureEither<List<SaleItem>> getSaleItems(String saleId);
  FutureEither<List<SaleServiceItem>> getSaleServiceItems(String saleId);

  /// Updates a sale record.
  FutureEither<Sale> updateSale(String id, Map<String, dynamic> data);

  /// Updates the order status of a sale.
  FutureEither<Sale> updateOrderStatus(String id, OrderStatus status);

  /// Updates the sale status (completed, refunded, voided).
  FutureEither<Sale> updateSaleStatus(String id, String status);

  /// Assigns machines to a sale service item.
  FutureEither<void> assignMachinesToServiceItem(
    String itemId,
    List<String> machineIds,
    List<String> machineNames,
  );

  /// Assigns storage locations to a sale service item.
  FutureEither<void> assignStoragesToServiceItem(
    String itemId,
    List<String> storageIds,
    List<String> storageNames,
  );

  /// Marks a service item as completed, releasing its machine.
  ///
  /// Returns `true` if all service items for the sale are now completed,
  /// indicating the order can be auto-advanced to 'ready' status.
  FutureEither<bool> markServiceItemCompleted(String itemId);

  /// Fetches all sales within a date range.
  FutureEither<List<Sale>> getSalesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  });

  /// Fetches all sales for a specific customer.
  FutureEither<List<Sale>> getSalesByCustomer(String customerId);

  /// Fetches sales with pagination.
  FutureEitherPaginated<Sale> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  });

  /// Searches sales with pagination.
  FutureEitherPaginated<Sale> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  });
}

@Riverpod(keepAlive: true)
SalesRepository salesRepository(Ref ref) {
  return SalesRepositoryImpl(ref.watch(pocketbaseProvider));
}

class SalesRepositoryImpl implements SalesRepository {
  final PocketBase _pb;

  SalesRepositoryImpl(this._pb);

  RecordService get _sales => _pb.collection(PocketBaseCollections.sales);
  RecordService get _saleItems =>
      _pb.collection(PocketBaseCollections.saleItems);
  RecordService get _saleServiceItems =>
      _pb.collection(PocketBaseCollections.saleServiceItems);
  RecordService get _statusHistory =>
      _pb.collection(PocketBaseCollections.orderStatusHistory);

  /// Fire-and-forget helper that logs a status change without blocking the caller.
  void _logStatusChange({
    required String saleId,
    required String statusType,
    required String fromStatus,
    required String toStatus,
    String? description,
  }) {
    final desc = description ??
        '${_capitalize(statusType == 'saleStatus' ? 'sale' : 'order')} status changed from ${_capitalize(fromStatus)} to ${_capitalize(toStatus)}';

    final body = OrderStatusHistoryDto.toCreateBody(
      saleId: saleId,
      statusType: statusType,
      fromStatus: fromStatus,
      toStatus: toStatus,
      description: desc,
    );

    _statusHistory.create(body: body).then(
          (_) {},
          onError: (e) => log('Failed to log status change: $e'),
        );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Sale _toSaleEntity(RecordModel record) {
    return SaleDto.fromRecord(record).toEntity();
  }

  SaleItem _toSaleItemEntity(RecordModel record) {
    final productExpanded = record.get<RecordModel?>('expand.product');
    return SaleItemDto.fromRecord(record)
        .toEntity(productExpanded: productExpanded);
  }

  SaleServiceItem _toSaleServiceItemEntity(RecordModel record) {
    final serviceExpanded = record.get<RecordModel?>('expand.service');
    final machineExpanded = record.get<RecordModel?>('expand.machine');
    final storageExpanded = record.get<List<RecordModel>?>('expand.storage');
    return SaleServiceItemDto.fromRecord(record).toEntity(
      serviceExpanded: serviceExpanded,
      machineExpanded: machineExpanded,
      storageExpanded: storageExpanded,
    );
  }

  @override
  FutureEither<Sale> createSale(
    Sale sale,
    List<SaleItem> items, {
    List<SaleServiceItem> serviceItems = const [],
  }) async {
    return TaskEither.tryCatch(
      () async {
        // 1. Create Sale Record with initial orderStatus: pending
        final saleBody = {
          'receiptNumber': sale.receiptNumber,
          'branch': sale.branchId,
          'cashier': sale.cashierId,
          'totalAmount': sale.totalAmount,
          'status': sale.status,
          'orderStatus': sale.orderStatus.name,
          'isPaid': sale.isPaid,
          'customer': sale.customerId,
          'customerName': sale.customerName,
          'notes': sale.notes,
        };
        final saleRecord = await _sales.create(body: saleBody);

        // 2. Create Sale Items (products)
        for (final item in items) {
          final itemBody = <String, dynamic>{
            'sale': saleRecord.id,
            'product': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'subtotal': item.subtotal,
          };
          if (item.productLotId != null && item.productLotId!.isNotEmpty) {
            itemBody['productLot'] = item.productLotId;
            itemBody['lotNumber'] = item.lotNumber;
          }
          await _saleItems.create(body: itemBody);
        }

        // 3. Create Sale Service Items
        for (final item in serviceItems) {
          final itemBody = <String, dynamic>{
            'sale': saleRecord.id,
            'service': item.serviceId,
            'serviceName': item.serviceName,
            'quantity': item.quantity.toInt(),
            'unitPrice': item.unitPrice,
            'subtotal': item.subtotal,
          };
          await _saleServiceItems.create(body: itemBody);
        }

        final createdSale = _toSaleEntity(saleRecord);

        // Fire-and-forget: log initial status entries
        _logStatusChange(
          saleId: saleRecord.id,
          statusType: 'saleStatus',
          fromStatus: '',
          toStatus: sale.status,
          description: 'Sale created with status ${_capitalize(sale.status)}',
        );
        _logStatusChange(
          saleId: saleRecord.id,
          statusType: 'orderStatus',
          fromStatus: '',
          toStatus: sale.orderStatus.name,
          description:
              'Sale created with order status ${sale.orderStatus.displayName}',
        );

        return createdSale;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> getSale(String id) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.getOne(id);
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateSale(String id, Map<String, dynamic> data) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.update(id, body: data);
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateOrderStatus(String id, OrderStatus status) async {
    return TaskEither.tryCatch(
      () async {
        // Fetch current sale to capture fromStatus
        final currentRecord = await _sales.getOne(id);
        final currentSale = _toSaleEntity(currentRecord);
        final fromOrderStatus = currentSale.orderStatus.name;

        final data = <String, dynamic>{
          'orderStatus': status.name,
        };
        // Set pickedUpAt and mark sale as completed when status changes to pickedUp
        if (status == OrderStatus.pickedUp) {
          data['pickedUpAt'] = DateTime.now().toUtc().toIso8601String();
          data['status'] = 'completed';
        }
        final record = await _sales.update(id, body: data);
        final updatedSale = _toSaleEntity(record);

        // Fire-and-forget: log order status change
        _logStatusChange(
          saleId: id,
          statusType: 'orderStatus',
          fromStatus: fromOrderStatus,
          toStatus: status.name,
        );

        // If pickedUp, also log the auto-transition of sale status to completed
        if (status == OrderStatus.pickedUp) {
          _logStatusChange(
            saleId: id,
            statusType: 'saleStatus',
            fromStatus: currentSale.status,
            toStatus: 'completed',
            description:
                'Sale automatically completed (order picked up)',
          );
        }

        return updatedSale;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateSaleStatus(String id, String status) async {
    return TaskEither.tryCatch(
      () async {
        // Fetch current sale to capture fromStatus
        final currentRecord = await _sales.getOne(id);
        final currentSale = _toSaleEntity(currentRecord);
        final fromStatus = currentSale.status;

        final record = await _sales.update(id, body: {'status': status});
        final updatedSale = _toSaleEntity(record);

        // Fire-and-forget: log sale status change
        _logStatusChange(
          saleId: id,
          statusType: 'saleStatus',
          fromStatus: fromStatus,
          toStatus: status,
        );

        return updatedSale;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Sale>> getSales({String? branchId, DateTime? date}) async {
    return TaskEither.tryCatch(
      () async {
        var filter = '';
        if (branchId != null) {
          filter = 'branch = "$branchId"';
        }

        if (date != null) {
          // Get start and end of day in local time, then convert to UTC for filter
          final localStart = DateTime(date.year, date.month, date.day);
          final localEnd = localStart.add(const Duration(days: 1));
          final dateFilter =
              'created >= "${localStart.toPocketBaseUtc()}" && created < "${localEnd.toPocketBaseUtc()}"';

          if (filter.isNotEmpty) {
            filter = '$filter && $dateFilter';
          } else {
            filter = dateFilter;
          }
        }

        final records = await _sales.getFullList(
          filter: filter.isEmpty ? null : filter,
          sort: '-created',
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SaleItem>> getSaleItems(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _saleItems.getFullList(
          filter: 'sale = "$saleId"',
          expand: 'product',
        );
        return records.map(_toSaleItemEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Sale> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final result = await _sales.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort ?? '-created',
        );

        return PaginatedResult<Sale>(
          items: result.items.map(_toSaleEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Sale> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Use PBFilter for multi-field OR search
        final searchFields = fields ?? ['receiptNumber'];
        final searchFilter =
            PBFilter().searchFields(query, searchFields).build();

        // Combine search filter with optional branch filter
        final combinedFilter =
            filter != null ? '$searchFilter && $filter' : searchFilter;

        final result = await _sales.getList(
          page: page,
          perPage: perPage,
          filter: combinedFilter,
          sort: sort ?? '-created',
        );

        return PaginatedResult<Sale>(
          items: result.items.map(_toSaleEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> assignMachinesToServiceItem(
    String itemId,
    List<String> machineIds,
    List<String> machineNames,
  ) async {
    return TaskEither.tryCatch(
      () async {
        await _saleServiceItems.update(itemId, body: {
          'machine': machineIds,
          'machineName': machineNames.join(', '),
          'status': 'in_progress',
        });
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> assignStoragesToServiceItem(
    String itemId,
    List<String> storageIds,
    List<String> storageNames,
  ) async {
    return TaskEither.tryCatch(
      () async {
        await _saleServiceItems.update(itemId, body: {
          'storage': storageIds,
          'storageName': storageNames.join(', '),
        });
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<bool> markServiceItemCompleted(String itemId) async {
    return TaskEither.tryCatch(
      () async {
        // 1. Update the service item status to 'completed'
        final updatedRecord = await _saleServiceItems.update(itemId, body: {
          'status': 'completed',
        });

        // 2. Get the sale ID from the updated record
        final saleId = updatedRecord.getStringValue('sale');
        if (saleId.isEmpty) {
          return false;
        }

        // 3. Fetch all service items for this sale
        final allItems = await _saleServiceItems.getFullList(
          filter: 'sale = "$saleId"',
        );

        // 4. Check if ALL items are now completed
        final allCompleted = allItems.every((item) {
          final status = item.getStringValue('status');
          return status == 'completed';
        });

        return allCompleted;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Sale>> getSalesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().between('created', startDate, endDate);
        if (branchId != null) {
          filter.relation('branch', branchId);
        }

        final records = await _sales.getFullList(
          filter: filter.build(),
          sort: '-created',
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Sale>> getSalesByCustomer(String customerId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _sales.getFullList(
          filter: 'customer = "$customerId"',
          sort: '-created',
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SaleServiceItem>> getSaleServiceItems(
      String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _saleServiceItems.getFullList(
          filter: 'sale = "$saleId"',
          expand: 'service.quantityUnit,machine,storage',
        );
        return records.map(_toSaleServiceItemEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
