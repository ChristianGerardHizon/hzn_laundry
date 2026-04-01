import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/customer_provider.dart';
import '../controllers/customers_controller.dart';
import '../widgets/customer_form_sheet.dart';

/// Customer detail page showing customer information and sales history.
class CustomerDetailPage extends HookConsumerWidget {
  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider(customerId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return customerAsync.when(
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Customer Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested customer could not be found.'),
            ),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(customerProvider(customerId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, ref),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, customer.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Customer info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Name', value: customer.name),
                      if (customer.phone != null && customer.phone!.isNotEmpty)
                        _InfoRow(label: 'Phone', value: customer.phone!),
                      if (customer.address != null &&
                          customer.address!.isNotEmpty)
                        _InfoRow(label: 'Address', value: customer.address!),
                      if (customer.notes != null && customer.notes!.isNotEmpty)
                        _InfoRow(label: 'Notes', value: customer.notes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sales history section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales History',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _CustomerSalesHistory(customerId: customerId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    final customer = ref.read(customerProvider(customerId)).value;
    if (customer == null) return;

    showCustomerFormDialog(context, customer: customer);
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String id,
  ) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Customer'),
          content:
              const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(customersControllerProvider.notifier)
            .deleteCustomer(id);
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Customer deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete customer');
        }
      }
    }
  }
}

/// Widget that fetches and displays sales history for a customer.
class _CustomerSalesHistory extends ConsumerWidget {
  const _CustomerSalesHistory({required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesRepo = ref.watch(salesRepositoryProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return FutureBuilder<List<Sale>>(
      future: _fetchCustomerSales(salesRepo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final sales = snapshot.data ?? [];

        if (sales.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color:
                        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No sales yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sales.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final sale = sales[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.receipt,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              title: Text('#${sale.receiptNumber}'),
              subtitle: Text(
                sale.created != null
                    ? dateFormat.format(sale.created!)
                    : 'Unknown date',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        sale.totalAmount.toCurrency(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sale.isPaid ? Icons.check_circle : Icons.pending,
                            size: 12,
                            color: sale.isPaid ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sale.isPaid ? 'Paid' : 'Unpaid',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: sale.isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              onTap: () => SaleDetailRoute(id: sale.id).go(context),
            );
          },
        );
      },
    );
  }

  Future<List<Sale>> _fetchCustomerSales(SalesRepository salesRepo) async {
    final result = await salesRepo.getSalesByCustomer(customerId);
    return result.fold(
      (failure) => [],
      (sales) => sales,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
