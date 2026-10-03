import 'package:flutter/material.dart';

import '../../../../core/widgets/list/app_list_row.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';

/// Labeled status chip for a sale in list rows (order stage or sale outcome).
class SaleListStatusChip extends StatelessWidget {
  const SaleListStatusChip({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final statusLower = sale.status.toLowerCase();
    if (statusLower == 'voided') {
      return const RowChip(label: 'Voided', color: Colors.red);
    }
    if (statusLower == 'refunded') {
      return const RowChip(label: 'Refunded', color: Colors.orange);
    }

    final (color, label) = switch (sale.orderStatus) {
      OrderStatus.pending => (Colors.amber.shade700, 'Pending'),
      OrderStatus.processing => (Colors.blue, 'Processing'),
      OrderStatus.ready => (Colors.green, 'Ready'),
      OrderStatus.forDelivery => (Colors.cyan, 'Out for delivery'),
      OrderStatus.pickedUp => (Colors.blueGrey, 'Fulfilled'),
    };

    return RowChip(label: label, color: color);
  }
}
