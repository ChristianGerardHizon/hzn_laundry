import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/controllers/customers_controller.dart';
import '../../../dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../sales/presentation/controllers/paginated_sales_controller.dart';
import '../../../services/domain/cart_service_item.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../domain/cart_item.dart';
import '../../domain/sale_item.dart';
import '../cart_controller.dart';
import '../checkout_controller.dart';
import 'receipt_dialog.dart';

/// Shows the checkout dialog.
Future<void> showCheckoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      insetPadding: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: _CheckoutDialogScaffold(),
    ),
  );
}

/// Wraps [CheckoutDialog] in a [ScaffoldMessenger] + [Scaffold] so that
/// snackbars rendered inside the dialog appear above it.
class _CheckoutDialogScaffold extends StatelessWidget {
  const _CheckoutDialogScaffold();

  @override
  Widget build(BuildContext context) {
    return const ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CheckoutDialog(),
      ),
    );
  }
}

/// Checkout dialog for completing a sale.
class CheckoutDialog extends HookConsumerWidget {
  const CheckoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // UI state
    final isSaving = useState(false);

    // Customer selection state
    final selectedCustomer = useState<Customer?>(null);

    // Watch cart state
    final cartState = ref.watch(cartControllerProvider);
    final cartItems = cartState.value?.items ?? [];
    final cartServiceItems = cartState.value?.serviceItems ?? [];
    final total = cartState.value?.total ?? 0;
    final cartIsEmpty = cartState.value?.isEmpty ?? true;

    Future<void> handleCheckout() async {
      // Validate customer is selected
      if (selectedCustomer.value == null) {
        showFormErrorDialog(
          context,
          errors: ['Please select a customer before completing the sale'],
        );
        return;
      }

      final isValid = formKey.currentState!.saveAndValidate();
      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);
        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;

      isSaving.value = true;

      // Determine customer info
      final customerId = selectedCustomer.value?.id;
      final customerName = selectedCustomer.value?.name;

      // Process checkout - create unpaid sale (payment handled separately)
      final result =
          await ref.read(checkoutControllerProvider.notifier).processCheckout(
                payNow: false,
                notes: values['notes'] as String?,
                customerId: customerId,
                customerName: customerName,
              );

      isSaving.value = false;

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showErrorSnackBar(context,
              message: failure.messageString, useRootMessenger: false);
        },
        (sale) {
          // Convert cart items to sale items for receipt
          final saleItems = cartItems
              .where((item) => item.product != null)
              .map((item) => SaleItem(
                    id: '',
                    saleId: sale.id,
                    productId: item.productId,
                    productName: item.product!.name,
                    quantity: item.quantity,
                    unitPrice: item.effectivePrice,
                    subtotal: item.total,
                    productLotId: item.productLotId,
                    lotNumber: item.lotNumber,
                  ))
              .toList();

          // Convert cart service items to sale service items for receipt
          final saleServiceItems = cartServiceItems
              .where((item) => item.service != null)
              .map((item) => SaleServiceItem(
                    id: '',
                    saleId: sale.id,
                    serviceId: item.serviceId,
                    serviceName: item.service!.name,
                    quantity: item.quantity,
                    unitPrice: item.effectivePrice,
                    subtotal: item.total,
                  ))
              .toList();

          // Refresh sales list & dashboard
          ref.invalidate(paginatedSalesControllerProvider);
          ref.invalidate(todaySalesSummaryProvider);
          ref.invalidate(kanbanSalesProvider);

          // Close checkout dialog
          context.pop();

          // Show receipt with items
          showReceiptDialog(
            context,
            sale: sale,
            saleItems: saleItems,
            saleServiceItems: saleServiceItems,
          );
        },
      );
    }

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isSaving.value ? null : () => context.pop(),
                    ),
                    Expanded(
                      child:
                          Text('Checkout', style: theme.textTheme.titleLarge),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: isSaving.value ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    FilledButton(
                      onPressed:
                          isSaving.value || cartIsEmpty ? null : handleCheckout,
                      child: isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Complete Sale'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Order summary
                      _buildOrderSummary(
                          context, cartItems, cartServiceItems, total),
                      const SizedBox(height: 24),

                      // Customer section (required)
                      _CustomerSelectionCard(
                        selectedCustomer: selectedCustomer,
                        ref: ref,
                      ),
                      const SizedBox(height: 24),

                      // Notes section
                      Card(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notes,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Additional Notes',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'notes',
                                decoration: const InputDecoration(
                                  labelText: 'Notes (Optional)',
                                  hintText:
                                      'Add any special instructions or comments',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.edit_note),
                                ),
                                maxLines: 2,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    List<CartItem> items,
    List<CartServiceItem> serviceItems,
    double total,
  ) {
    final theme = Theme.of(context);
    final totalQuantity = items.fold<int>(
            0, (sum, item) => sum + item.quantity.toInt()) +
        serviceItems.fold<int>(0, (sum, item) => sum + item.quantity.toInt());

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with icon and item count
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalQuantity items',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product item rows
            ...items.map((item) {
              final product = item.product;
              if (product == null) return const SizedBox.shrink();
              return _buildSummaryRow(
                theme,
                name: product.name,
                quantity: item.quantity,
                unitPrice: item.effectivePrice,
                subtotal: item.total,
              );
            }),

            // Service item rows
            if (serviceItems.isNotEmpty && items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.miscellaneous_services,
                        size: 12, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Services',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            Divider(color: theme.colorScheme.outlineVariant)),
                  ],
                ),
              ),
            ...serviceItems.map((item) {
              final service = item.service;
              final unit = service?.quantityUnit;
              final unitLabel = unit != null
                  ? (item.quantity == 1 ? unit.shortSingular : unit.shortPlural)
                  : null;
              return _buildSummaryRow(
                theme,
                name: service?.name ?? 'Service',
                quantity: item.quantity,
                unitPrice: item.effectivePrice,
                subtotal: item.total,
                unitLabel: unitLabel,
              );
            }),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Total row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    total.toCurrency(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme, {
    required String name,
    required num quantity,
    required num unitPrice,
    required num subtotal,
    String? unitLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              unitLabel != null
                  ? '${quantity.toInt()}$unitLabel'
                  : '${quantity.toInt()}x',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('@ ${unitPrice.toCurrency()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Text(subtotal.toCurrency(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

const _fieldLabels = {
  'notes': 'Notes',
};

/// Card widget for customer search/select with inline creation.
class _CustomerSelectionCard extends HookConsumerWidget {
  const _CustomerSelectionCard({
    required this.selectedCustomer,
    required this.ref,
  });

  final ValueNotifier<Customer?> selectedCustomer;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customersAsync = ref.watch(customersControllerProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isSearching = useState(false);

    final customers = customersAsync.value ?? [];
    final filteredCustomers = searchQuery.value.isEmpty
        ? <Customer>[]
        : customers.where((c) {
            final query = searchQuery.value.toLowerCase();
            return c.name.toLowerCase().contains(query) ||
                (c.phone?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with icon
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Quick Add'),
                  onPressed: () async {
                    final customer =
                        await _showQuickAddCustomerDialog(context, ref);
                    if (customer != null) {
                      selectedCustomer.value = customer;
                      searchController.text = customer.name;
                      isSearching.value = false;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Selected customer display or search field
            if (selectedCustomer.value != null && !isSearching.value) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCustomer.value!.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (selectedCustomer.value!.phone != null)
                            Text(
                              selectedCustomer.value!.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        selectedCustomer.value = null;
                        searchController.clear();
                        searchQuery.value = '';
                        isSearching.value = true;
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search customer by name or phone',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  hintText: 'Type to search...',
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                  isSearching.value = true;
                },
              ),

              // Search results dropdown
              if (searchQuery.value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: filteredCustomers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No customers found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(customer.name),
                              subtitle: Text(customer.phone ?? ''),
                              onTap: () {
                                selectedCustomer.value = customer;
                                searchController.text = customer.name;
                                searchQuery.value = '';
                                isSearching.value = false;
                              },
                            );
                          },
                        ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<Customer?> _showQuickAddCustomerDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog<Customer?>(
      context: context,
      builder: (context) => const _QuickAddCustomerDialog(),
    );
  }
}

class _QuickAddCustomerDialog extends HookConsumerWidget {
  const _QuickAddCustomerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final customerData = Customer(
        id: '',
        name: values['name'] as String,
        phone: values['phone'] as String,
      );

      final controller = ref.read(customersControllerProvider.notifier);
      final created = await controller.createCustomer(customerData);

      isSaving.value = false;

      if (created != null && context.mounted) {
        Navigator.of(context).pop(created);
      } else if (context.mounted) {
        showErrorSnackBar(
          context,
          message: 'Failed to create customer',
          useRootMessenger: false,
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: const Text('Quick Add Customer'),
          content: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => handleSave(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : handleSave,
              child: isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
