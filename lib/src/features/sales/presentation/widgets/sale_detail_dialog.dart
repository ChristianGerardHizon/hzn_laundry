import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/printing/order_claim_sheet_pdf.dart';
import '../../../../core/routing/dialog_dismissing_observer.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../controllers/sale_items_provider.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';
import 'record_payment_sheet.dart';
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

            // Footer with payment + view details buttons
            _DialogFooter(
              saleId: saleId,
              sale: saleAsync.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer with optional "Record Payment" button and "View Full Details".
class _DialogFooter extends ConsumerWidget {
  const _DialogFooter({
    required this.saleId,
    required this.sale,
  });

  final String saleId;
  final Sale? sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showPayment =
        sale != null && !sale!.isPaid; // shows for unpaid and partial
    final totalPaidAsync =
        showPayment ? ref.watch(saleTotalPaidProvider(saleId)) : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPayment) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final totalPaid = totalPaidAsync?.value ?? 0;
                  final balanceDue = sale!.totalAmount - totalPaid;
                  final result = await showRecordPaymentDialog(
                    context,
                    sale: sale!,
                    balanceDue: balanceDue,
                  );
                  if (result == true) {
                    ref.invalidate(saleProvider(saleId));
                    ref.invalidate(salePaymentsProvider(saleId));
                    ref.invalidate(kanbanSalesProvider);
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text('Record Payment'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                DialogDismissingObserver.dismissAllDialogs();
                SaleDetailRoute(id: saleId).go(context);
              },
              child: const Text('View Full Details'),
            ),
          ),
        ],
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
    final saleItemsAsync = ref.watch(saleItemsProvider(saleId));

    OrderClaimSheetPdfData buildPdfData({required bool storeCopy}) {
      final serviceItems = serviceItemsAsync.value ?? [];
      final firstService = serviceItems.isNotEmpty ? serviceItems.first : null;
      final addOnItems = saleItemsAsync.value ?? [];
      final service = firstService?.service;
      final unitLabel = service?.quantityUnit?.shortPlural ??
          (service?.weightBased == true ? 'KG' : 'PCS');
      final currentBranch = branchAsync.value;

      return OrderClaimSheetPdfData(
        customerName: sale.customerName ?? 'Walk-in',
        serviceName: firstService?.serviceName ?? 'Laundry',
        quantity: firstService?.quantity.toDouble() ?? 1.0,
        unitLabel: unitLabel,
        totalAmount: sale.totalAmount.toDouble(),
        createdDate: sale.postedDate ?? DateTime.now(),
        storeCopy: storeCopy,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: sale.notes,
        claimSheetNumber: sale.receiptNumber,
        addOnItems: addOnItems,
      );
    }

    Future<void> printCopy(OrderReceiptCopy copyType) async {
      if (isPrinting.value) return;

      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context, message: 'No default printer configured');
        return;
      }

      final pdfData = buildPdfData(
        storeCopy: copyType == OrderReceiptCopy.store,
      );

      isPrinting.value = true;
      try {
        final printService = ref.read(thermalPrintServiceProvider.notifier);

        final result = await printService.printOrderReceipt(
          printer: printer,
          customerName: pdfData.customerName,
          serviceName: pdfData.serviceName,
          quantity: pdfData.quantity,
          unitLabel: pdfData.unitLabel,
          totalAmount: pdfData.totalAmount,
          claimSheetNumber: pdfData.claimSheetNumber,
          copyType: copyType,
          businessName: pdfData.businessName,
          branchAddress: pdfData.branchAddress,
          contactNumber: pdfData.contactNumber,
          cashierName: pdfData.cashierName,
          specialInstructions: pdfData.specialInstructions,
          addOnItems: pdfData.addOnItems,
        );

        if (!context.mounted) return;

        if (result is PrintFailure) {
          showErrorSnackBar(context, message: result.message);
        } else {
          final label = copyType == OrderReceiptCopy.customer
              ? 'Claim sheet'
              : 'Claim sheet (store)';
          showSuccessSnackBar(context, message: '$label printed');
        }
      } finally {
        if (context.mounted) isPrinting.value = false;
      }
    }

    Future<void> previewCopy({required bool storeCopy}) async {
      if (isPrinting.value) return;

      isPrinting.value = true;
      try {
        final pdfData = buildPdfData(storeCopy: storeCopy);
        await previewOrderClaimSheetPdf(context: context, data: pdfData);
      } finally {
        if (context.mounted) isPrinting.value = false;
      }
    }

    Future<void> handleMenuSelection(String value) async {
      switch (value) {
        case 'print_customer':
          await printCopy(OrderReceiptCopy.customer);
        case 'print_store':
          await printCopy(OrderReceiptCopy.store);
        case 'preview_customer':
          await previewCopy(storeCopy: false);
        case 'preview_store':
          await previewCopy(storeCopy: true);
      }
    }

    return PopupMenuButton<String>(
      icon: isPrinting.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.print, size: 20),
      tooltip: 'Print & preview',
      enabled: !isPrinting.value,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: handleMenuSelection,
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'print_customer',
          child: ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Print Claim Sheet'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem<String>(
          value: 'print_store',
          child: ListTile(
            leading: Icon(Icons.local_laundry_service),
            title: Text('Print Claim Sheet (Store)'),
            subtitle: Text('Machine tag'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'preview_customer',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined),
            title: Text('Preview Claim Sheet'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem<String>(
          value: 'preview_store',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined),
            title: Text('Preview Claim Sheet (Store)'),
            subtitle: Text('Machine tag'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
