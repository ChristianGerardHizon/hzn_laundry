import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';
import 'sale_detail_content.dart';

/// Dialog that displays sale details in a compact format.
///
/// Shows the core sale information and provides a "View Full Details"
/// button to navigate to the full sale detail page.
class SaleDetailDialog extends HookConsumerWidget {
  const SaleDetailDialog({
    super.key,
    required this.saleId,
  });

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saleAsync = ref.watch(saleProvider(saleId));

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title, print buttons, and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Print menu
                  if (saleAsync.value != null)
                    _DialogPrintMenu(
                      sale: saleAsync.value!,
                      saleId: saleId,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: saleAsync.when(
                data: (sale) {
                  if (sale == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sale not found'),
                      ),
                    );
                  }
                  return SaleDetailContent(
                    sale: sale,
                    compact: true,
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () => ref.invalidate(saleProvider(saleId)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer with "View Full Details" button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SaleDetailRoute(id: saleId).go(context);
                  },
                  child: const Text('View Full Details'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the sale detail dialog.
///
/// Returns a Future that completes when the dialog is dismissed.
Future<void> showSaleDetailDialog(
  BuildContext context, {
  required String saleId,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => SaleDetailDialog(saleId: saleId),
  );
}

// ── Print menu for the dialog header ─────────────────────────────────────────

class _DialogPrintMenu extends HookConsumerWidget {
  const _DialogPrintMenu({
    required this.sale,
    required this.saleId,
  });

  final Sale sale;
  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrinting = useState(false);
    final defaultPrinterAsync = ref.watch(defaultPrinterProvider);
    final currentAuth = ref.watch(currentAuthProvider);
    final branchId = ref.watch(currentBranchIdProvider);
    final branchAsync = ref.watch(branchProvider(branchId ?? ''));
    final serviceItemsAsync = ref.watch(saleServiceItemsProvider(saleId));

    Future<void> printCopy(OrderReceiptCopy copyType) async {
      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context,
            message: 'No default printer configured');
        return;
      }

      final serviceItems = serviceItemsAsync.value ?? [];
      final firstService = serviceItems.isNotEmpty ? serviceItems.first : null;

      isPrinting.value = true;
      final printService = ref.read(thermalPrintServiceProvider.notifier);
      final currentBranch = branchAsync.value;

      final result = await printService.printOrderReceipt(
        printer: printer,
        customerName: sale.customerName ?? 'Walk-in',
        serviceName: firstService?.serviceName ?? 'Laundry',
        quantity: firstService?.quantity.toDouble() ?? 1.0,
        unitLabel: 'PCS',
        totalAmount: sale.totalAmount.toDouble(),
        copyType: copyType,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: sale.notes,
      );

      isPrinting.value = false;
      if (!context.mounted) return;

      if (result is PrintFailure) {
        showErrorSnackBar(context, message: result.message);
      } else {
        final label = copyType == OrderReceiptCopy.customer
            ? 'Customer copy'
            : 'Store copy';
        showSuccessSnackBar(context, message: '$label printed');
      }
    }

    return PopupMenuButton<OrderReceiptCopy>(
      icon: isPrinting.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.print, size: 20),
      tooltip: 'Print',
      enabled: !isPrinting.value,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: printCopy,
      itemBuilder: (context) => const [
        PopupMenuItem<OrderReceiptCopy>(
          value: OrderReceiptCopy.customer,
          child: ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Print Customer Copy'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem<OrderReceiptCopy>(
          value: OrderReceiptCopy.store,
          child: ListTile(
            leading: Icon(Icons.local_laundry_service),
            title: Text('Print Store Copy'),
            subtitle: Text('Machine tag'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
