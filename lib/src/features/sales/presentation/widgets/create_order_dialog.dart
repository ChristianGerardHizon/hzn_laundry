import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/printing/order_claim_sheet_pdf.dart';
import '../../../../core/routing/dialog_dismissing_observer.dart';
import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/controllers/customers_controller.dart';
import '../../../customers/presentation/widgets/customer_form_sheet.dart';
import '../../../dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../services/domain/service.dart';
import '../../../services/domain/service_price_tier.dart';
import '../../../services/presentation/controllers/service_price_tiers_provider.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../../../pos/presentation/components/variable_price_dialog.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../../../promos/data/repositories/customer_promo_repository.dart';
import '../../../promos/data/repositories/promo_repository.dart';
import '../../../promos/domain/customer_promo.dart';
import '../../../promos/presentation/controllers/redeemable_promos_provider.dart';
import '../../../promos/presentation/widgets/loyalty_rewards_section.dart';
import '../../presentation/controllers/paginated_sales_controller.dart';

/// Generates a receipt number in format: S-YYMMDD-XXXX
String _generateReceiptNumber() {
  final now = DateTime.now();
  final year = (now.year % 100).toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final datePart = '$year$month$day';

  final random = Random();
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final suffix =
      List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();

  return 'S-$datePart-$suffix';
}

/// A product added to the order with its quantity.
class _OrderProductItem {
  _OrderProductItem({
    required this.product,
    this.quantity = 1,
    this.customPrice,
  });

  final Product product;
  int quantity;
  final num? customPrice;

  num get effectivePrice => customPrice ?? product.price;
  num get subtotal => effectivePrice * quantity;
}

/// Shows the Create New Order dialog.
///
/// On mobile it fills the screen; on desktop/tablet it displays as a
/// constrained dialog (max 600 px wide).
Future<void> showCreateOrderDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => const _CreateOrderDialogScaffold(),
  );
}

class _CreateOrderDialogScaffold extends StatelessWidget {
  const _CreateOrderDialogScaffold();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 600;

    return Dialog(
      insetPadding: isWide
          ? const EdgeInsets.symmetric(horizontal: 80, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: const _CreateOrderDialog(),
      ),
    );
  }
}

/// Internal dialog widget.
class _CreateOrderDialog extends HookConsumerWidget {
  const _CreateOrderDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    // Customer selection
    final selectedCustomer = useState<Customer?>(null);

    // Service selection
    final selectedService = useState<Service?>(null);

    // Price tiers for the selected service
    final tiersAsync = selectedService.value != null
        ? ref.watch(servicePriceTiersProvider(selectedService.value!.id))
        : null;
    final tiers = tiersAsync?.value ?? [];

    // Quantity & notes
    final quantity = useState<double>(1.0);
    final orderDate = useMemoized(() => DateTime.now());

    // Custom service subtotal override (null = use computed price * qty)
    final customServiceTotal = useState<double?>(null);

    // Product items
    final productItems = useState<List<_OrderProductItem>>([]);

    // Tracks whether order was created → show success page
    final orderCreated = useState(false);
    final createdReceiptNumber = useState<String?>(null);

    // Loyalty promo redemption
    final selectedPromoRedemption = useState<CustomerPromo?>(null);

    // Dirty tracking
    final isDirty = useState(false);

    Future<bool> confirmDiscard() async {
      if (!isDirty.value) return true;
      final result = await showDiscardChangesDialog(context);
      return result;
    }

    Future<void> handleClose() async {
      if (await confirmDiscard()) {
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    Future<void> handleCreateOrder() async {
      if (selectedCustomer.value == null) {
        showErrorSnackBar(
          context,
          message: 'Please select a customer',
          useRootMessenger: false,
        );
        return;
      }

      if (selectedService.value == null) {
        showErrorSnackBar(
          context,
          message: 'Please select a service',
          useRootMessenger: false,
        );
        return;
      }

      if (!formKey.currentState!.saveAndValidate()) return;

      final auth = ref.read(currentAuthProvider);
      if (auth == null) {
        showErrorSnackBar(context,
            message: 'Not authenticated', useRootMessenger: false);
        return;
      }

      final branchId = ref.read(currentBranchIdProvider);
      if (branchId == null) {
        showErrorSnackBar(context,
            message: 'No branch selected', useRootMessenger: false);
        return;
      }

      isSaving.value = true;

      final service = selectedService.value!;
      final customer = selectedCustomer.value!;
      final qty = quantity.value;
      final tieredUnitPrice =
          resolveTieredPrice(tiers, qty, service.price).toDouble();
      final computedServiceTotal = tiers.isEmpty
          ? (tieredUnitPrice * qty).toDouble()
          : resolveTieredTotal(tiers, qty, service.price).toDouble();
      final serviceTotal = customServiceTotal.value ?? computedServiceTotal;
      final effectiveUnitPrice = qty > 0 ? serviceTotal / qty : tieredUnitPrice;
      final productsTotal = productItems.value.fold<double>(
        0.0,
        (sum, item) => sum + item.subtotal.toDouble(),
      );
      final subtotal = serviceTotal + productsTotal;

      // Calculate loyalty discount
      double loyaltyDiscount = 0.0;
      final redeemPromo = selectedPromoRedemption.value;
      if (redeemPromo != null && redeemPromo.promo != null) {
        final freeWeight = redeemPromo.promo!.rewardFreeWeight.toDouble();
        loyaltyDiscount =
            (freeWeight * effectiveUnitPrice).clamp(0.0, serviceTotal);
      }

      final total = (subtotal - loyaltyDiscount).clamp(0.0, double.infinity);
      final userNotes =
          formKey.currentState?.fields['specialInstructions']?.value as String?;

      // Append loyalty info to notes
      String? notes = userNotes;
      if (redeemPromo != null && redeemPromo.promo != null) {
        final loyaltyNote =
            'Loyalty: ${redeemPromo.promo!.rewardDisplay} via ${redeemPromo.promo!.name}';
        notes = notes != null && notes.isNotEmpty
            ? '$notes\n$loyaltyNote'
            : loyaltyNote;
      }

      final receiptNumber = _generateReceiptNumber();

      final sale = Sale(
        id: '',
        receiptNumber: receiptNumber,
        branchId: branchId,
        cashierId: auth.user.id,
        totalAmount: total,
        status: 'pending',
        orderStatus: OrderStatus.pending,
        isPaid: false,
        customerId: customer.id,
        customerName: customer.name,
        notes: notes,
      );

      final serviceItem = SaleServiceItem(
        id: '',
        saleId: '',
        serviceId: service.id,
        serviceName: service.name,
        quantity: qty,
        unitPrice: effectiveUnitPrice,
        subtotal: serviceTotal,
      );

      final saleItems = productItems.value
          .map((item) => SaleItem(
                id: '',
                saleId: '',
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                unitPrice: item.effectivePrice,
                subtotal: item.subtotal,
              ))
          .toList();

      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.createSale(
        sale,
        saleItems,
        serviceItems: [serviceItem],
      );

      isSaving.value = false;

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showErrorSnackBar(context,
              message: failure.messageString, useRootMessenger: false);
        },
        (createdSale) {
          // Handle loyalty promo redemption + increment (fire-and-forget)
          final customerPromoRepo = ref.read(customerPromoRepositoryProvider);
          final promoRepo = ref.read(promoRepositoryProvider);
          final branchFilter = ref.read(currentBranchFilterProvider);

          if (redeemPromo != null) {
            customerPromoRepo.redeemReward(redeemPromo.id, createdSale.id);
          }

          // Increment order counts and auto-enroll
          customerPromoRepo.incrementAndAutoEnroll(
            customer.id,
            promoRepo,
            excludeCustomerPromoId: redeemPromo?.id,
            branchFilter: branchFilter,
          );

          // Invalidate promo providers for this customer
          ref.invalidate(redeemablePromosProvider(customer.id));

          // Refresh dashboard and sales list
          ref.invalidate(kanbanSalesProvider);
          ref.invalidate(notPickedUpCountProvider);
          ref.invalidate(todaySalesSummaryProvider);
          ref.invalidate(paginatedSalesControllerProvider);

          orderCreated.value = true;
          createdReceiptNumber.value = createdSale.receiptNumber;
        },
      );
    }

    final displayUnitPrice = selectedService.value == null
        ? 0.0
        : resolveTieredPrice(
                tiers, quantity.value, selectedService.value!.price)
            .toDouble();
    final computedServiceTotal = selectedService.value == null
        ? 0.0
        : tiers.isEmpty
            ? (displayUnitPrice * quantity.value).toDouble()
            : resolveTieredTotal(
                    tiers, quantity.value, selectedService.value!.price)
                .toDouble();
    final serviceTotal = customServiceTotal.value ?? computedServiceTotal;
    final productsTotal = productItems.value.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal.toDouble(),
    );
    final subtotalDisplay = serviceTotal + productsTotal;

    // Calculate loyalty discount for display
    double displayLoyaltyDiscount = 0.0;
    if (selectedPromoRedemption.value?.promo != null &&
        selectedService.value != null) {
      final freeWeight =
          selectedPromoRedemption.value!.promo!.rewardFreeWeight.toDouble();
      displayLoyaltyDiscount =
          (freeWeight * displayUnitPrice).clamp(0.0, serviceTotal);
    }

    final estimatedTotal =
        (subtotalDisplay - displayLoyaltyDiscount).clamp(0.0, double.infinity);

    // ── Success page after order creation ──────────────────────────────
    if (orderCreated.value) {
      return DialogCloseHandler(
        child: _OrderSuccessPage(
          customer: selectedCustomer.value!,
          service: selectedService.value!,
          quantity: quantity.value,
          orderDate: orderDate,
          specialInstructions: formKey
              .currentState?.fields['specialInstructions']?.value as String?,
          estimatedTotal: estimatedTotal,
          productItems: productItems.value,
          claimSheetNumber: createdReceiptNumber.value,
        ),
      );
    }

    // ── Order form ──────────────────────────────────────────────────────
    return DialogCloseHandler(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _DialogHeader(
            isSaving: isSaving.value,
            onClose: handleClose,
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Flexible(
            child: FormBuilder(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Customer selection
                    _SectionLabel(
                      label: 'Customer Selection',
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('New Customer'),
                        onPressed: isSaving.value
                            ? null
                            : () {
                                showCustomerFormDialog(
                                  context,
                                  onSaved: (created) {
                                    selectedCustomer.value = created;
                                    isDirty.value = true;
                                  },
                                );
                              },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CustomerSearchField(
                      selectedCustomer: selectedCustomer,
                      enabled: !isSaving.value,
                      onChanged: () {
                        isDirty.value = true;
                        selectedPromoRedemption.value = null;
                      },
                      ref: ref,
                    ),
                    const SizedBox(height: 12),

                    // Loyalty rewards (only when customer selected)
                    if (selectedCustomer.value != null)
                      LoyaltyRewardsSection(
                        customerId: selectedCustomer.value!.id,
                        selectedPromo: selectedPromoRedemption.value,
                        onPromoSelected: (promo) {
                          selectedPromoRedemption.value = promo;
                          isDirty.value = true;
                        },
                        enabled: !isSaving.value,
                      ),
                    const SizedBox(height: 8),

                    // Service selection
                    _SectionLabel(label: 'Service Selection'),
                    const SizedBox(height: 8),
                    _ServiceSelector(
                      selectedService: selectedService,
                      enabled: !isSaving.value,
                      onChanged: () {
                        isDirty.value = true;
                        customServiceTotal.value = null;
                      },
                      ref: ref,
                    ),
                    const SizedBox(height: 20),

                    // Quantity & Order Date
                    _QuantityStepper(
                      quantity: quantity,
                      unitLabel:
                          selectedService.value?.quantityUnit?.shortPlural ??
                              (selectedService.value?.weightBased == false
                                  ? 'PCS'
                                  : 'kg'),
                      enabled: !isSaving.value,
                      onChanged: () {
                        isDirty.value = true;
                        customServiceTotal.value = null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Service subtotal (editable)
                    if (selectedService.value != null)
                      _ServiceSubtotal(
                        service: selectedService.value!,
                        quantity: quantity.value,
                        tiers: tiers,
                        customTotal: customServiceTotal.value,
                        enabled: !isSaving.value,
                        onCustomTotalChanged: (value) {
                          customServiceTotal.value = value;
                          isDirty.value = true;
                        },
                      ),
                    const SizedBox(height: 20),

                    // Products (optional add-ons)
                    _ProductsSection(
                      productItems: productItems,
                      enabled: !isSaving.value,
                      onChanged: () => isDirty.value = true,
                    ),
                    const SizedBox(height: 20),

                    // Special instructions
                    _SpecialInstructionsField(
                      enabled: !isSaving.value,
                      onChanged: () => isDirty.value = true,
                    ),
                    const SizedBox(height: 20),

                    // Order date (read-only)
                    _OrderDateDisplay(date: orderDate),
                  ],
                ),
              ),
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────────
          _DialogFooter(
            estimatedTotal: estimatedTotal,
            subtotal: subtotalDisplay,
            loyaltyDiscount: displayLoyaltyDiscount,
            isSaving: isSaving.value,
            canCreate:
                selectedCustomer.value != null && selectedService.value != null,
            onCreateOrder: handleCreateOrder,
          ),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.isSaving, required this.onClose});

  final bool isSaving;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Order',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill in the details to initiate a laundry request.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: isSaving ? null : onClose,
          ),
        ],
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.estimatedTotal,
    this.subtotal = 0,
    this.loyaltyDiscount = 0,
    required this.isSaving,
    required this.canCreate,
    required this.onCreateOrder,
  });

  final double estimatedTotal;
  final double subtotal;
  final double loyaltyDiscount;
  final bool isSaving;
  final bool canCreate;
  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = loyaltyDiscount > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasDiscount) ...[
                  Row(
                    children: [
                      Text(
                        'Subtotal: ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        subtotal.toCurrency(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.loyalty,
                          size: 12, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Discount: -${loyaltyDiscount.toCurrency()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ] else
                  Text(
                    'ESTIMATED TOTAL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                Text(
                  estimatedTotal.toCurrency(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: isSaving || !canCreate ? null : onCreateOrder,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Order'),
          ),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ── Customer search field ────────────────────────────────────────────────────

class _CustomerSearchField extends HookConsumerWidget {
  const _CustomerSearchField({
    required this.selectedCustomer,
    required this.enabled,
    required this.onChanged,
    required this.ref,
  });

  final ValueNotifier<Customer?> selectedCustomer;
  final bool enabled;
  final VoidCallback onChanged;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isSearching = useState(false);

    final customersAsync = ref.watch(customersControllerProvider);
    final customers = customersAsync.value ?? [];

    final filtered = searchQuery.value.isEmpty
        ? <Customer>[]
        : customers.where((c) {
            final q = searchQuery.value.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                (c.phone?.toLowerCase().contains(q) ?? false);
          }).toList();

    if (selectedCustomer.value != null && !isSearching.value) {
      return _SelectedCustomerTile(
        customer: selectedCustomer.value!,
        onEdit: () {
          showCustomerFormDialog(
            context,
            customer: selectedCustomer.value!,
            onSaved: (updated) {
              selectedCustomer.value = updated;
              onChanged();
            },
          );
        },
        onClear: () {
          selectedCustomer.value = null;
          searchController.clear();
          searchQuery.value = '';
          isSearching.value = true;
          onChanged();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Search by name, phone or ID...',
            prefixIcon: const Icon(Icons.manage_search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (v) {
            searchQuery.value = v;
            isSearching.value = true;
          },
        ),
        if (searchQuery.value.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: () {
              final hasExactMatch = filtered.any(
                (c) => c.name.toLowerCase() == searchQuery.value.toLowerCase(),
              );
              return ListView(
                shrinkWrap: true,
                children: [
                  ...filtered.map((c) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(c.name),
                        subtitle: c.phone != null ? Text(c.phone!) : null,
                        onTap: () {
                          selectedCustomer.value = c;
                          searchController.text = c.name;
                          searchQuery.value = '';
                          isSearching.value = false;
                          onChanged();
                        },
                      )),
                  if (!hasExactMatch)
                    ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.tertiaryContainer,
                        child: Icon(
                          Icons.person_add,
                          size: 16,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      title: Text(
                        'Create "${searchQuery.value}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        showCustomerFormDialog(
                          context,
                          initialName: searchQuery.value,
                          onSaved: (customer) {
                            selectedCustomer.value = customer;
                            searchController.text = customer.name;
                            searchQuery.value = '';
                            isSearching.value = false;
                            onChanged();
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              );
            }(),
          ),
        ],
      ],
    );
  }
}

class _SelectedCustomerTile extends StatelessWidget {
  const _SelectedCustomerTile({
    required this.customer,
    required this.onEdit,
    required this.onClear,
  });

  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Icon(
              Icons.person,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (customer.phone != null)
                  Text(
                    customer.phone!,
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
              Icons.edit,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Edit customer',
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

// ── Service selector ─────────────────────────────────────────────────────────

class _ServiceSelector extends HookConsumerWidget {
  const _ServiceSelector({
    required this.selectedService,
    required this.enabled,
    required this.onChanged,
    required this.ref,
  });

  final ValueNotifier<Service?> selectedService;
  final bool enabled;
  final VoidCallback onChanged;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesControllerProvider);
    final services = servicesAsync.value ?? [];
    final activeServices = services.where((s) => !s.isDeleted).toList();

    // Auto-select: prefer the default service, else the first if only one
    useEffect(() {
      if (selectedService.value != null) return null;
      final defaultService = activeServices
          .cast<Service?>()
          .firstWhere((s) => s!.isDefault, orElse: () => null);
      final autoSelect = defaultService ??
          (activeServices.length == 1 ? activeServices.first : null);
      if (autoSelect != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          selectedService.value = autoSelect;
          onChanged();
        });
      }
      return null;
    }, [activeServices.length]);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const columns = 3;
        final chipWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: activeServices.map((service) {
            final isSelected = selectedService.value?.id == service.id;
            return SizedBox(
              width: chipWidth,
              child: _ServiceChip(
                service: service,
                isSelected: isSelected,
                enabled: enabled,
                onTap: () {
                  if (!enabled) return;
                  selectedService.value = isSelected ? null : service;
                  onChanged();
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.service,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final Service service;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  // Maps service names to icons (best-effort matching).
  static IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wash') || lower.contains('laundry')) {
      return Icons.local_laundry_service;
    }
    if (lower.contains('dry')) return Icons.dry_cleaning;
    if (lower.contains('iron') || lower.contains('press')) {
      return Icons.iron;
    }
    if (lower.contains('fold')) return Icons.layers;
    return Icons.cleaning_services;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(service.name), size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              service.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quantity stepper ─────────────────────────────────────────────────────────

class _QuantityStepper extends HookWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unitLabel,
    required this.enabled,
    required this.onChanged,
  });

  final ValueNotifier<double> quantity;
  final String unitLabel;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = useState(false);
    final textController = useTextEditingController(
      text: quantity.value.toStringAsFixed(1),
    );
    final focusNode = useFocusNode();

    // Sync controller text when quantity changes externally (stepper buttons)
    useEffect(() {
      if (!isEditing.value) {
        textController.text = quantity.value.toStringAsFixed(1);
      }
      return null;
    }, [quantity.value]);

    void commitEdit() {
      final parsed = double.tryParse(textController.text);
      if (parsed != null && parsed > 0) {
        quantity.value = double.parse(parsed.toStringAsFixed(1));
        onChanged();
      } else {
        textController.text = quantity.value.toStringAsFixed(1);
      }
      isEditing.value = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              // Minus
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: enabled && quantity.value > 0.5
                    ? () {
                        quantity.value = double.parse(
                            (quantity.value - 0.5).toStringAsFixed(1));
                        onChanged();
                      }
                    : null,
              ),
              // Value — tappable to edit
              Expanded(
                child: GestureDetector(
                  onTap: enabled
                      ? () {
                          isEditing.value = true;
                          textController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: textController.text.length,
                          );
                          focusNode.requestFocus();
                        }
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isEditing.value)
                        TextField(
                          controller: textController,
                          focusNode: focusNode,
                          enabled: enabled,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => commitEdit(),
                          onTapOutside: (_) => commitEdit(),
                        )
                      else
                        Text(
                          quantity.value.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      Text(
                        unitLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Plus
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: enabled
                    ? () {
                        quantity.value = double.parse(
                            (quantity.value + 0.5).toStringAsFixed(1));
                        onChanged();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Service subtotal (editable) ──────────────────────────────────────────────

class _ServiceSubtotal extends StatelessWidget {
  const _ServiceSubtotal({
    required this.service,
    required this.quantity,
    required this.tiers,
    required this.customTotal,
    required this.enabled,
    required this.onCustomTotalChanged,
  });

  final Service service;
  final double quantity;
  final List<ServicePriceTier> tiers;
  final double? customTotal;
  final bool enabled;
  final ValueChanged<double?> onCustomTotalChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unitPrice =
        resolveTieredPrice(tiers, quantity, service.price).toDouble();
    final computed = tiers.isEmpty
        ? (unitPrice * quantity).toDouble()
        : resolveTieredTotal(tiers, quantity, service.price).toDouble();
    final displayTotal = customTotal ?? computed;
    final isOverridden = customTotal != null;
    final isTiered = tiers.isNotEmpty;
    final unitLabel = service.quantityUnit?.shortPlural ?? 'kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOverridden
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverridden
              ? theme.colorScheme.tertiary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Subtotal',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          displayTotal.toCurrency(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOverridden
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isOverridden) ...[
                          const SizedBox(width: 8),
                          Text(
                            computed.toCurrency(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!isOverridden)
                      Text(
                        isTiered
                            ? 'Flat rate for ${quantity.toStringAsFixed(1)} $unitLabel'
                            : '${unitPrice.toCurrency()} x ${quantity.toStringAsFixed(1)} $unitLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (isOverridden)
                      Text(
                        'Price adjusted by cashier',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              if (isOverridden)
                IconButton(
                  icon: Icon(
                    Icons.undo,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                  tooltip: 'Reset to computed price',
                  onPressed: enabled ? () => onCustomTotalChanged(null) : null,
                ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'Adjust subtotal',
                onPressed: enabled
                    ? () async {
                        final result = await _showSubtotalEditDialog(
                          context,
                          currentTotal: displayTotal,
                          computedTotal: computed,
                        );
                        if (result != null) {
                          onCustomTotalChanged(result);
                        }
                      }
                    : null,
              ),
            ],
          ),
          // Tier breakdown
          if (tiers.isNotEmpty) ...[
            const SizedBox(height: 8),
            _TierBreakdown(
              tiers: tiers,
              currentQuantity: quantity,
              unitLabel: unitLabel,
            ),
          ],
        ],
      ),
    );
  }

  Future<double?> _showSubtotalEditDialog(
    BuildContext context, {
    required double currentTotal,
    required double computedTotal,
  }) {
    final formKey = GlobalKey<FormBuilderState>();

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Service Subtotal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base price: ${computedTotal.toCurrency()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            FormBuilder(
              key: formKey,
              child: FormBuilderTextField(
                name: 'subtotal',
                initialValue: currentTotal.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Subtotal',
                  prefixText: '₱ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0),
                ]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final value = double.tryParse(
                  formKey.currentState?.fields['subtotal']?.value ?? '',
                );
                Navigator.pop(context, value);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// ── Tier breakdown ──────────────────────────────────────────────────────────

class _TierBreakdown extends HookWidget {
  const _TierBreakdown({
    required this.tiers,
    required this.currentQuantity,
    required this.unitLabel,
  });

  final List<ServicePriceTier> tiers;
  final double currentQuantity;
  final String unitLabel;

  static const _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = useState(false);
    final sorted = [...tiers]
      ..sort((a, b) => a.minQuantity.compareTo(b.minQuantity));

    // Find which tier is active
    int activeIndex = -1;
    for (var i = 0; i < sorted.length; i++) {
      final nextMin = i + 1 < sorted.length ? sorted[i + 1].minQuantity : null;
      if (sorted[i].containsQuantityWithNext(
        currentQuantity,
        nextTierMin: nextMin,
      )) {
        activeIndex = i;
        break;
      }
    }

    // Determine which tiers to show when collapsed
    final canCollapse = sorted.length > _visibleCount;
    List<int> visibleIndices;
    if (!canCollapse || isExpanded.value) {
      visibleIndices = List.generate(sorted.length, (i) => i);
    } else {
      // Show a window of 3 tiers centered on the active tier
      int start;
      if (activeIndex <= 0) {
        start = 0;
      } else if (activeIndex >= sorted.length - 1) {
        start = sorted.length - _visibleCount;
      } else {
        start = activeIndex - 1;
      }
      start = start.clamp(0, sorted.length - _visibleCount);
      visibleIndices = List.generate(_visibleCount, (i) => start + i);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price tiers',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...visibleIndices.map((i) {
            final tier = sorted[i];
            final isActive = i == activeIndex;
            final nextTierMin =
                i + 1 < sorted.length ? sorted[i + 1].minQuantity : null;
            final rangeText =
                tier.displayRange(unitLabel, nextTierMin: nextTierMin);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  if (isActive)
                    Icon(
                      Icons.arrow_right,
                      size: 14,
                      color: theme.colorScheme.primary,
                    )
                  else
                    const SizedBox(width: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rangeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${tier.pricePerUnit.toCurrency()}/$unitLabel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (canCollapse)
            GestureDetector(
              onTap: () => isExpanded.value = !isExpanded.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded.value
                          ? 'Show less'
                          : 'Show all ${sorted.length} tiers',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      isExpanded.value ? Icons.expand_less : Icons.expand_more,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Special instructions ─────────────────────────────────────────────────────

class _SpecialInstructionsField extends StatelessWidget {
  const _SpecialInstructionsField({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: 'specialInstructions',
          enabled: enabled,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Use hypoallergenic detergent, extra dry...',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

// ── Add-ons section ─────────────────────────────────────────────────────────

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({
    required this.productItems,
    required this.enabled,
    required this.onChanged,
  });

  final ValueNotifier<List<_OrderProductItem>> productItems;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = productItems.value;
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final addOnsTotal = items.fold<num>(0, (sum, item) => sum + item.subtotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Row(
          children: [
            Text(
              'Add-ons',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            TextButton.icon(
              onPressed: enabled ? () => _showAddOnsSheet(context) : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),

        // Added items list
        if (items.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 12,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  _AddOnItemRow(
                    item: items[i],
                    currencyFormat: currencyFormat,
                    enabled: enabled,
                    onIncrement: () {
                      final updated = List<_OrderProductItem>.from(items);
                      updated[i] = _OrderProductItem(
                        product: items[i].product,
                        quantity: items[i].quantity + 1,
                        customPrice: items[i].customPrice,
                      );
                      productItems.value = updated;
                      onChanged();
                    },
                    onDecrement: () {
                      final updated = List<_OrderProductItem>.from(items);
                      if (items[i].quantity <= 1) {
                        updated.removeAt(i);
                      } else {
                        updated[i] = _OrderProductItem(
                          product: items[i].product,
                          quantity: items[i].quantity - 1,
                          customPrice: items[i].customPrice,
                        );
                      }
                      productItems.value = updated;
                      onChanged();
                    },
                    onRemove: () {
                      final updated = List<_OrderProductItem>.from(items);
                      updated.removeAt(i);
                      productItems.value = updated;
                      onChanged();
                    },
                  ),
                ],
                // Subtotal
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Subtotal: ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      currencyFormat.format(addOnsTotal),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showAddOnsSheet(BuildContext context) async {
    final result = await showDialog<List<_OrderProductItem>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddOnsPickerDialog(
        currentItems: productItems.value,
      ),
    );
    if (result != null) {
      productItems.value = result;
      onChanged();
    }
  }
}

/// A single add-on item row with quantity controls.
class _AddOnItemRow extends StatelessWidget {
  const _AddOnItemRow({
    required this.item,
    required this.currencyFormat,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final _OrderProductItem item;
  final NumberFormat currencyFormat;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${currencyFormat.format(item.effectivePrice)} each',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Quantity stepper
        Container(
          decoration: BoxDecoration(
            border:
                Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: enabled ? onDecrement : null,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(6)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Icon(Icons.remove,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: enabled ? onIncrement : null,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(6)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Icon(Icons.add,
                      size: 14, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            currencyFormat.format(item.subtotal),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        SizedBox(
          width: 28,
          child: IconButton(
            icon: Icon(Icons.close,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: enabled ? onRemove : null,
          ),
        ),
      ],
    );
  }
}

/// Dialog for picking add-on products.
class _AddOnsPickerDialog extends HookConsumerWidget {
  const _AddOnsPickerDialog({required this.currentItems});

  final List<_OrderProductItem> currentItems;

  int _qtyForProduct(List<_OrderProductItem> items, String productId) {
    int total = 0;
    for (final item in items) {
      if (item.product.id == productId) total += item.quantity;
    }
    return total;
  }

  bool _hasChanges(List<_OrderProductItem> current) {
    if (current.length != currentItems.length) return true;
    for (int i = 0; i < current.length; i++) {
      if (current[i].product.id != currentItems[i].product.id ||
          current[i].quantity != currentItems[i].quantity) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final productsAsync = useState<List<Product>?>(null);
    final isLoading = useState(true);
    final items = useState(List<_OrderProductItem>.from(currentItems));
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    useEffect(() {
      () async {
        final repo = ref.read(productRepositoryProvider);
        final result = await repo.fetchAll(
          filter: "isDeleted = false && forSale = true",
          sort: 'name',
        );
        result.fold(
          (_) {},
          (products) => productsAsync.value = products,
        );
        isLoading.value = false;
      }();
      return null;
    }, []);

    final allProducts = productsAsync.value ?? [];
    final filtered = searchQuery.value.isEmpty
        ? allProducts
        : allProducts.where((p) {
            final q = searchQuery.value.toLowerCase();
            return p.name.toLowerCase().contains(q);
          }).toList();

    final addedCount =
        items.value.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal =
        items.value.fold<num>(0, (sum, item) => sum + item.subtotal);

    Future<void> handleDiscard() async {
      if (!_hasChanges(items.value)) {
        Navigator.of(context).pop();
        return;
      }
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
              'You have unsaved add-on changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard == true && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text(
                    'Add-ons',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (addedCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$addedCount item${addedCount == 1 ? '' : 's'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: handleDiscard,
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search add-ons...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onChanged: (v) => searchQuery.value = v,
              ),
            ),
            const SizedBox(height: 8),
            // Product list
            Expanded(
              child: isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            allProducts.isEmpty
                                ? 'No add-ons available'
                                : 'No matching add-ons',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final product = filtered[i];
                            final qty = _qtyForProduct(items.value, product.id);
                            final isAdded = qty > 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: isAdded
                                                ? FontWeight.w600
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          product.isVariablePrice
                                              ? 'Variable price'
                                              : currencyFormat
                                                  .format(product.price),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdded)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.primaryContainer
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              qty == 1
                                                  ? Icons.delete_outline
                                                  : Icons.remove,
                                              size: 18,
                                              color: qty == 1
                                                  ? theme.colorScheme.error
                                                  : theme.colorScheme.primary,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            constraints: const BoxConstraints(
                                                minWidth: 36, minHeight: 36),
                                            onPressed: () {
                                              final updated =
                                                  List<_OrderProductItem>.from(
                                                      items.value);
                                              final idx =
                                                  updated.lastIndexWhere((e) =>
                                                      e.product.id ==
                                                      product.id);
                                              if (idx != -1) {
                                                if (updated[idx].quantity <=
                                                    1) {
                                                  updated.removeAt(idx);
                                                } else {
                                                  updated[idx] =
                                                      _OrderProductItem(
                                                    product:
                                                        updated[idx].product,
                                                    quantity:
                                                        updated[idx].quantity -
                                                            1,
                                                    customPrice: updated[idx]
                                                        .customPrice,
                                                  );
                                                }
                                              }
                                              items.value = updated;
                                            },
                                          ),
                                          Text(
                                            '$qty',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            constraints: const BoxConstraints(
                                                minWidth: 36, minHeight: 36),
                                            onPressed: () {
                                              final updated =
                                                  List<_OrderProductItem>.from(
                                                      items.value);
                                              final idx =
                                                  updated.lastIndexWhere((e) =>
                                                      e.product.id ==
                                                      product.id);
                                              if (idx != -1) {
                                                updated[idx] =
                                                    _OrderProductItem(
                                                  product: updated[idx].product,
                                                  quantity:
                                                      updated[idx].quantity + 1,
                                                  customPrice:
                                                      updated[idx].customPrice,
                                                );
                                              }
                                              items.value = updated;
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: theme.colorScheme.primary,
                                      ),
                                      onPressed: () async {
                                        num? price;
                                        if (product.isVariablePrice) {
                                          price = await showVariablePriceDialog(
                                            context,
                                            productName: product.name,
                                          );
                                          if (price == null) return;
                                        }
                                        final updated =
                                            List<_OrderProductItem>.from(
                                                items.value);
                                        updated.add(_OrderProductItem(
                                          product: product,
                                          customPrice: price,
                                        ));
                                        items.value = updated;
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            // Footer with subtotal and save/discard
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (items.value.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Subtotal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          currencyFormat.format(subtotal),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: handleDiscard,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(items.value),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order date display ────────────────────────────────────────────────────────

class _OrderDateDisplay extends StatelessWidget {
  const _OrderDateDisplay({required this.date});

  final DateTime date;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Order success page ──────────────────────────────────────────────────────

class _OrderSuccessPage extends HookConsumerWidget {
  const _OrderSuccessPage({
    required this.customer,
    required this.service,
    required this.quantity,
    required this.orderDate,
    required this.estimatedTotal,
    this.specialInstructions,
    this.productItems = const [],
    this.claimSheetNumber,
  });

  final Customer customer;
  final Service service;
  final double quantity;
  final DateTime orderDate;
  final double estimatedTotal;
  final String? specialInstructions;
  final List<_OrderProductItem> productItems;
  final String? claimSheetNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final isPrinting = useState(false);
    final hasAutoPrinted = useState(false);
    final printStoreCopy = useState(true);
    final defaultPrinterAsync = ref.watch(defaultPrinterProvider);
    final currentAuth = ref.watch(currentAuthProvider);
    final branchId = ref.watch(currentBranchIdProvider);
    final branchAsync = ref.watch(branchProvider(branchId ?? ''));
    final hasDefaultPrinter = defaultPrinterAsync.value != null;
    final canThermalPrint =
        isThermalPrintingSupported && hasDefaultPrinter;

    final unitLabel = service.quantityUnit?.shortPlural ??
        (service.weightBased == true ? 'KG' : 'PCS');

    // Convert product items to SaleItem for receipt printing
    final addOnSaleItems = productItems
        .map((item) => SaleItem(
              id: '',
              saleId: '',
              productId: item.product.id,
              productName: item.product.name,
              quantity: item.quantity,
              unitPrice: item.effectivePrice,
              subtotal: item.subtotal,
            ))
        .toList();

    OrderClaimSheetPdfData buildPdfData({required bool storeCopy}) {
      final currentBranch = branchAsync.value;
      return OrderClaimSheetPdfData(
        customerName: customer.name,
        serviceName: service.name,
        quantity: quantity,
        unitLabel: unitLabel,
        totalAmount: estimatedTotal,
        createdDate: orderDate,
        storeCopy: storeCopy,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: specialInstructions,
        claimSheetNumber: claimSheetNumber,
        addOnItems: addOnSaleItems,
      );
    }

    Future<void> handlePdfPreview({required bool storeCopy}) async {
      if (isPrinting.value) return;

      isPrinting.value = true;
      try {
        await previewOrderClaimSheetPdf(
          context: context,
          data: buildPdfData(storeCopy: storeCopy),
        );
      } finally {
        if (context.mounted) isPrinting.value = false;
      }
    }

    Future<void> handlePreviewMenuSelection(String value) async {
      switch (value) {
        case 'preview_customer':
          await handlePdfPreview(storeCopy: false);
        case 'preview_store':
          await handlePdfPreview(storeCopy: true);
      }
    }

    Future<void> handleThermalPrint({bool showSuccessMessage = true}) async {
      if (!isThermalPrintingSupported) {
        showErrorSnackBar(
          context,
          message: kThermalPrintingUnsupportedMessage,
          useRootMessenger: false,
        );
        return;
      }

      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context,
            message: 'No default printer configured', useRootMessenger: false);
        return;
      }

      isPrinting.value = true;
      final printService = ref.read(thermalPrintServiceProvider.notifier);
      final currentBranch = branchAsync.value;

      // Print store copy first (compact machine tag) so staff can start work
      if (printStoreCopy.value) {
        final storeResult = await printService.printOrderReceipt(
          printer: printer,
          customerName: customer.name,
          serviceName: service.name,
          quantity: quantity,
          unitLabel: unitLabel,
          totalAmount: estimatedTotal,
          copyType: OrderReceiptCopy.store,
          claimSheetNumber: claimSheetNumber,
          businessName: currentBranch?.name,
          branchAddress: currentBranch?.address,
          contactNumber: currentBranch?.contactNumber,
          cashierName: currentAuth?.user.name,
          specialInstructions: specialInstructions,
          addOnItems: addOnSaleItems,
        );

        if (storeResult is PrintFailure) {
          isPrinting.value = false;
          if (context.mounted) {
            showErrorSnackBar(context,
                message: storeResult.message, useRootMessenger: false);
          }
          return;
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Print customer copy (full receipt)
      final customerResult = await printService.printOrderReceipt(
        printer: printer,
        customerName: customer.name,
        serviceName: service.name,
        quantity: quantity,
        unitLabel: unitLabel,
        totalAmount: estimatedTotal,
        copyType: OrderReceiptCopy.customer,
        claimSheetNumber: claimSheetNumber,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: specialInstructions,
        addOnItems: addOnSaleItems,
      );

      if (customerResult is PrintFailure) {
        isPrinting.value = false;
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: printStoreCopy.value
                ? 'Claim sheet printed (customer copy failed)'
                : customerResult.message,
            useRootMessenger: false,
          );
        }
        return;
      }

      isPrinting.value = false;
      if (!context.mounted) return;

      if (showSuccessMessage) {
        final msg = printStoreCopy.value
            ? 'Printed: store + customer claim sheets'
            : 'Claim sheet printed';
        showSuccessSnackBar(context, message: msg, useRootMessenger: false);
      }
    }

    // Auto-print when page appears if a default printer is set
    useEffect(() {
      final printer = defaultPrinterAsync.value;
      if (isThermalPrintingSupported &&
          printer != null &&
          !hasAutoPrinted.value &&
          !isPrinting.value) {
        hasAutoPrinted.value = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          handleThermalPrint(showSuccessMessage: true);
        });
      }
      return null;
    }, [defaultPrinterAsync.value]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text('Claim Sheet', style: theme.textTheme.titleLarge),
              ),
              PopupMenuButton<String>(
                tooltip: 'Generate PDF',
                enabled: !isPrinting.value,
                icon: isPrinting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                onSelected: handlePreviewMenuSelection,
                itemBuilder: (context) => const [
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
              ),
              const SizedBox(width: 4),
              if (canThermalPrint)
                FilledButton.icon(
                  onPressed: isPrinting.value ? null : handleThermalPrint,
                  icon: isPrinting.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  label: Text(isPrinting.value ? 'Printing...' : 'Print'),
                )
              else if (isThermalPrintingSupported)
                TextButton(
                  onPressed: () {
                    DialogDismissingObserver.dismissAllDialogs();
                    const PrinterSettingsRoute().go(context);
                  },
                  child: const Text('Setup Printer'),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Success icon ────────────────────────────────────────────────
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 40, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Order Created!',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // ── Order details ───────────────────────────────────────────────
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'Customer', customer.name),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, 'Service', service.name),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, 'Quantity',
                      '${quantity.toStringAsFixed(1)} $unitLabel'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      context, 'Date', dateFormat.format(orderDate)),
                  if (specialInstructions != null &&
                      specialInstructions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        context, 'Instructions', specialInstructions!),
                  ],
                  const SizedBox(height: 16),
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          estimatedTotal.toCurrency(),
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
          ),
        ),
        const SizedBox(height: 16),

        // ── Cashier copy option ─────────────────────────────────────────
        if (canThermalPrint)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CheckboxListTile(
              value: printStoreCopy.value,
              onChanged: (v) => printStoreCopy.value = v ?? true,
              title: const Text('Print store claim sheet'),
              subtitle: const Text('Prints a compact tag for machines'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),

        // ── Done button ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: canThermalPrint
                ? OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  )
                : FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
