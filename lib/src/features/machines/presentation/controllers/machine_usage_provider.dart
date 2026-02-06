import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';

part 'machine_usage_provider.g.dart';

/// Information about a machine's current usage status.
class MachineUsageInfo {
  const MachineUsageInfo({
    required this.isInUse,
    required this.activeOrderCount,
    required this.receiptNumbers,
  });

  /// Whether the machine is currently assigned to any processing order.
  final bool isInUse;

  /// Number of active orders using this machine.
  final int activeOrderCount;

  /// Receipt numbers of the orders using this machine.
  final List<String> receiptNumbers;

  /// Returns a display string for the first receipt number.
  String? get firstReceiptNumber =>
      receiptNumbers.isNotEmpty ? receiptNumbers.first : null;

  /// Returns a display string summarizing all active orders.
  String get displaySummary {
    if (receiptNumbers.isEmpty) return '';
    if (receiptNumbers.length == 1) return 'Order #${receiptNumbers.first}';
    return 'Orders: ${receiptNumbers.map((r) => '#$r').join(', ')}';
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
      receiptNumbers: [],
    );
  }

  final pb = ref.watch(pocketbaseProvider);

  // Query saleServiceItems where machine = machineId
  // and expand the sale relation to check orderStatus
  final records = await pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
    filter: 'machine = "$machineId"',
    expand: 'sale',
  );

  final processingReceiptNumbers = <String>[];

  for (final record in records) {
    // Use the newer get<T>(keyPath) API with dot-notation
    final orderStatus = record.get<String?>('expand.sale.orderStatus');
    if (orderStatus == 'processing') {
      final receiptNumber = record.get<String?>('expand.sale.receiptNumber');
      if (receiptNumber != null &&
          receiptNumber.isNotEmpty &&
          !processingReceiptNumbers.contains(receiptNumber)) {
        processingReceiptNumbers.add(receiptNumber);
      }
    }
  }

  return MachineUsageInfo(
    isInUse: processingReceiptNumbers.isNotEmpty,
    activeOrderCount: processingReceiptNumbers.length,
    receiptNumbers: processingReceiptNumbers,
  );
}
