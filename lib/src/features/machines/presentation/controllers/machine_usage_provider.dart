import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';

part 'machine_usage_provider.g.dart';

/// Details about an order currently using a machine.
class MachineUsageOrder {
  const MachineUsageOrder({
    required this.receiptNumber,
    required this.isBacklog,
  });

  final String receiptNumber;

  /// Whether this order was created before today (a backlog order).
  final bool isBacklog;

  /// Short display label, e.g. "#X7KP" or "#X7KP (Backlog)".
  String get displayLabel {
    final short = _shortOrderNumber(receiptNumber);
    return isBacklog ? '$short (Backlog)' : short;
  }

  static String _shortOrderNumber(String receiptNumber) {
    final parts = receiptNumber.split('-');
    if (parts.length >= 3) return '#${parts.last}';
    if (receiptNumber.length > 4) {
      return '#${receiptNumber.substring(receiptNumber.length - 4)}';
    }
    return receiptNumber;
  }
}

/// Information about a machine's current usage status.
class MachineUsageInfo {
  const MachineUsageInfo({
    required this.isInUse,
    required this.activeOrderCount,
    required this.orders,
  });

  /// Whether the machine is currently assigned to any processing order.
  final bool isInUse;

  /// Number of active orders using this machine.
  final int activeOrderCount;

  /// Orders currently using this machine.
  final List<MachineUsageOrder> orders;

  /// Receipt numbers of the orders using this machine.
  List<String> get receiptNumbers => orders.map((o) => o.receiptNumber).toList();

  /// Returns a display string for the first receipt number.
  String? get firstReceiptNumber =>
      receiptNumbers.isNotEmpty ? receiptNumbers.first : null;

  /// Returns a display string summarizing all active orders using short labels.
  String get displaySummary {
    if (orders.isEmpty) return '';
    if (orders.length == 1) return 'Order ${orders.first.displayLabel}';
    return 'Orders: ${orders.map((o) => o.displayLabel).join(', ')}';
  }
}

/// Provider that checks if a machine is currently in use.
///
/// A machine is considered "in use" if it's assigned to any saleServiceItem
/// whose parent sale has orderStatus == "processing".
@riverpod
Future<MachineUsageInfo> machineUsage(Ref ref, String machineId) async {
  if (machineId.isEmpty) {
    return const MachineUsageInfo(
      isInUse: false,
      activeOrderCount: 0,
      orders: [],
    );
  }

  final pb = ref.watch(pocketbaseProvider);

  // Query saleServiceItems where machine = machineId
  // and expand the sale relation to check orderStatus
  final records = await pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
    filter: 'machine ~ "$machineId"',
    expand: 'sale',
  );

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final seenReceipts = <String>{};
  final orders = <MachineUsageOrder>[];

  for (final record in records) {
    // Use the newer get<T>(keyPath) API with dot-notation
    final orderStatus = record.get<String?>('expand.sale.orderStatus');
    if (orderStatus == 'processing') {
      // Check the service item's status - machine is only "in use" if
      // the service item is not completed
      final itemStatus = record.get<String?>('status');
      if (itemStatus == 'completed') {
        // Service item is done, machine is available
        continue;
      }

      final receiptNumber = record.get<String?>('expand.sale.receiptNumber');
      if (receiptNumber != null &&
          receiptNumber.isNotEmpty &&
          !seenReceipts.contains(receiptNumber)) {
        seenReceipts.add(receiptNumber);

        final createdStr = record.get<String?>('expand.sale.created');
        final created = createdStr != null
            ? DateTime.tryParse(createdStr)?.toLocal()
            : null;
        final isBacklog = created != null && created.isBefore(todayStart);

        orders.add(MachineUsageOrder(
          receiptNumber: receiptNumber,
          isBacklog: isBacklog,
        ));
      }
    }
  }

  return MachineUsageInfo(
    isInUse: orders.isNotEmpty,
    activeOrderCount: orders.length,
    orders: orders,
  );
}
