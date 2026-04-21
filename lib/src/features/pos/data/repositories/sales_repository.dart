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
import '../dto/sale_dto.dart';
import '../dto/sale_item_dto.dart';

part 'sales_repository.g.dart';

abstract class SalesRepository {
  FutureEither<Sale> createSale(
    Sale sale,
    List<SaleItem> items, {
    List<SaleServiceItem> serviceItems,
    DateTime? postedDate,
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
    List<String> machineNames, {
    Map<String, int> loadCounts = const {},
  });

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

  /// Fetches pre-aggregated sale service totals from the view collection.
  FutureEither<List<RecordModel>> getSaleServiceTotals({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    bool filterByProcessedDate = false,
  });

  /// Fetches optimized rows used by dashboard today incentive calculations.
  FutureEither<List<RecordModel>> getTodayIncentiveRows({
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

  /// Updates a sale item's quantity, unitPrice, and subtotal.
  FutureEither<void> updateSaleItem(
    String itemId, {
    required num quantity,
    required num unitPrice,
    required num subtotal,
  });

  /// Updates a sale service item's quantity, unitPrice, and subtotal.
  FutureEither<void> updateSaleServiceItem(
    String itemId, {
    required num quantity,
    required num unitPrice,
    required num subtotal,
  });

  /// Recalculates and updates the sale's totalAmount from all its items.
  FutureEither<Sale> recalculateSaleTotal(String saleId);
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
    DateTime? postedDate,
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
          'paymentStatus': sale.isPaid ? 'paid' : 'unpaid',
          'customer': sale.customerId,
          'customerName': sale.customerName,
          'notes': sale.notes,
          'postedDate':
              (postedDate ?? DateTime.now()).toUtc().toIso8601String(),
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
        final data = <String, dynamic>{
          'orderStatus': status.name,
        };
        // Set pickedUpAt and mark sale as completed when status changes to pickedUp
        if (status == OrderStatus.pickedUp) {
          data['pickedUpAt'] = DateTime.now().toUtc().toIso8601String();
          data['status'] = 'completed';
        }
        final record = await _sales.update(id, body: data);
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateSaleStatus(String id, String status) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.update(id, body: {'status': status});
        return _toSaleEntity(record);
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
              'postedDate >= "${localStart.toPocketBaseUtc()}" && postedDate < "${localEnd.toPocketBaseUtc()}"';

          if (filter.isNotEmpty) {
            filter = '$filter && $dateFilter';
          } else {
            filter = dateFilter;
          }
        }

        final records = await _sales.getFullList(
          filter: filter.isEmpty ? null : filter,
          sort: '-postedDate',
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
          sort: sort ?? '-postedDate',
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
          sort: sort ?? '-postedDate',
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
    List<String> machineNames, {
    Map<String, int> loadCounts = const {},
  }) async {
    return TaskEither.tryCatch(
      () async {
        await _saleServiceItems.update(itemId, body: {
          'machine': machineIds,
          'machineName': machineNames.join(', '),
          'machineLoadCounts': loadCounts,
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
        final filter = PBFilter()
            .notEquals('status', 'voided')
            .between('postedDate', startDate, endDate);
        if (branchId != null) {
          filter.relation('branch', branchId);
        }

        final records = await _sales.getFullList(
          filter: filter.build(),
          sort: '-postedDate',
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<RecordModel>> getSaleServiceTotals({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    bool filterByProcessedDate = false,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter();

        if (filterByProcessedDate) {
          // Attribute incentives to the day the order was first processed
          // (status changed to ready/pickedUp), stamped by the hook.
          filter.between('processedDate', startDate, endDate);
        } else {
          // Default: filter by postedDate; fall back to created for older records.
          final postedFilter =
              PBFilter().between('postedDate', startDate, endDate);
          final createdFilter = PBFilter()
              .isNull('postedDate')
              .and(PBFilter().between('created', startDate, endDate));
          filter.or(postedFilter).or(createdFilter);
        }

        if (branchId != null) {
          filter.relation('branch', branchId);
        }

        final records = await _pb
            .collection(PocketBaseCollections.vwSaleServiceTotals)
            .getFullList(
              filter: filter.build(),
              sort: filterByProcessedDate ? '-processedDate' : '-postedDate',
            );
        return records;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<RecordModel>> getTodayIncentiveRows({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter =
            PBFilter().between('effectiveProcessedDate', startDate, endDate);
        if (branchId != null) {
          filter.relation('branch', branchId);
        }

        final records = await _pb
            .collection(PocketBaseCollections.vwSaleServiceTotals)
            .getFullList(
              filter: filter.build(),
              sort: '-effectiveProcessedDate',
            );
        return records;
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
          sort: '-postedDate',
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SaleServiceItem>> getSaleServiceItems(String saleId) async {
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

  @override
  FutureEither<void> updateSaleItem(
    String itemId, {
    required num quantity,
    required num unitPrice,
    required num subtotal,
  }) async {
    return TaskEither.tryCatch(
      () async {
        await _saleItems.update(itemId, body: {
          'quantity': quantity,
          'unitPrice': unitPrice,
          'subtotal': subtotal,
        });
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> updateSaleServiceItem(
    String itemId, {
    required num quantity,
    required num unitPrice,
    required num subtotal,
  }) async {
    return TaskEither.tryCatch(
      () async {
        await _saleServiceItems.update(itemId, body: {
          'quantity': quantity,
          'unitPrice': unitPrice,
          'subtotal': subtotal,
        });
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> recalculateSaleTotal(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        // Sum all sale items
        final items = await _saleItems.getFullList(
          filter: 'sale = "$saleId"',
        );
        num itemsTotal = 0;
        for (final item in items) {
          itemsTotal += item.getDoubleValue('subtotal');
        }

        // Sum all service items
        final serviceItems = await _saleServiceItems.getFullList(
          filter: 'sale = "$saleId"',
        );
        num serviceTotal = 0;
        for (final item in serviceItems) {
          serviceTotal += item.getDoubleValue('subtotal');
        }

        final newTotal = itemsTotal + serviceTotal;
        final record = await _sales.update(saleId, body: {
          'totalAmount': newTotal,
        });

        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
