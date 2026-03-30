import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/controllers/customers_controller.dart';
import '../../../services/domain/service.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';

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
    return Builder(
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: _CreateOrderDialog(),
      ),
    );
  }
}

/// Internal dialog widget.
class _CreateOrderDialog extends HookConsumerWidget {
  const _CreateOrderDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 600;

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    // Customer selection
    final selectedCustomer = useState<Customer?>(null);

    // Service selection
    final selectedService = useState<Service?>(null);

    // Quantity & notes
    final quantity = useState<double>(1.0);
    final orderDate = useMemoized(() => DateTime.now());

    // Tracks whether order was created → show success page
    final orderCreated = useState(false);

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

      isSaving.value = true;

      // TODO: Implement order creation via controller/repository
      await Future.delayed(const Duration(milliseconds: 500));

      isSaving.value = false;

      if (!context.mounted) return;

      orderCreated.value = true;
    }

    final estimatedTotal = selectedService.value == null
        ? 0.0
        : (selectedService.value!.price * quantity.value).toDouble();

    // ── Success page after order creation ──────────────────────────────
    if (orderCreated.value) {
      return DialogCloseHandler(
        child: Scaffold(
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
              maxHeight: size.height * 0.92,
            ),
            child: _OrderSuccessPage(
              customer: selectedCustomer.value!,
              service: selectedService.value!,
              quantity: quantity.value,
              orderDate: orderDate,
              specialInstructions: formKey.currentState
                  ?.fields['specialInstructions']?.value as String?,
              estimatedTotal: estimatedTotal,
            ),
          ),
        ),
      );
    }

    // ── Order form ──────────────────────────────────────────────────────
    return DialogCloseHandler(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: size.height * 0.92,
        ),
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
                              : () async {
                                  final created =
                                      await _showQuickAddCustomerDialog(
                                          context, ref);
                                  if (created != null) {
                                    selectedCustomer.value = created;
                                    isDirty.value = true;
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CustomerSearchField(
                        selectedCustomer: selectedCustomer,
                        enabled: !isSaving.value,
                        onChanged: () => isDirty.value = true,
                        ref: ref,
                      ),
                      const SizedBox(height: 20),

                      // Service selection
                      _SectionLabel(label: 'Service Selection'),
                      const SizedBox(height: 8),
                      _ServiceSelector(
                        selectedService: selectedService,
                        enabled: !isSaving.value,
                        onChanged: () => isDirty.value = true,
                        ref: ref,
                      ),
                      const SizedBox(height: 20),

                      // Quantity & Order Date
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _QuantityStepper(
                                quantity: quantity,
                                unitLabel: selectedService
                                        .value?.quantityUnit?.shortPlural ??
                                    (selectedService.value?.weightBased == true
                                        ? 'KG'
                                        : 'PCS'),
                                enabled: !isSaving.value,
                                onChanged: () => isDirty.value = true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _OrderDateDisplay(date: orderDate),
                            ),
                          ],
                        )
                      else ...[
                        _QuantityStepper(
                          quantity: quantity,
                          unitLabel: selectedService
                                  .value?.quantityUnit?.shortPlural ??
                              (selectedService.value?.weightBased == true
                                  ? 'KG'
                                  : 'PCS'),
                          enabled: !isSaving.value,
                          onChanged: () => isDirty.value = true,
                        ),
                        const SizedBox(height: 20),
                        _OrderDateDisplay(date: orderDate),
                      ],
                      const SizedBox(height: 20),

                      // Special instructions
                      _SpecialInstructionsField(
                        enabled: !isSaving.value,
                        onChanged: () => isDirty.value = true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────────
            _DialogFooter(
              estimatedTotal: estimatedTotal,
              isSaving: isSaving.value,
              canCreate: selectedCustomer.value != null &&
                  selectedService.value != null,
              onCreateOrder: handleCreateOrder,
            ),
          ],
        ),
      ),
    );
  }

  Future<Customer?> _showQuickAddCustomerDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showDialog<Customer?>(
      context: context,
      builder: (_) => _QuickAddCustomerDialog(ref: ref),
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
    required this.isSaving,
    required this.canCreate,
    required this.onCreateOrder,
  });

  final double estimatedTotal;
  final bool isSaving;
  final bool canCreate;
  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ESTIMATED TOTAL',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    estimatedTotal.toCurrency(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Incl. Tax',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
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
            child: filtered.isEmpty
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
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return ListTile(
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
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

class _SelectedCustomerTile extends StatelessWidget {
  const _SelectedCustomerTile({
    required this.customer,
    required this.onClear,
  });

  final Customer customer;
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

    // Auto-select when there is exactly one service (deferred to avoid
    // setState during build)
    useEffect(() {
      if (activeServices.length == 1 && selectedService.value == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          selectedService.value = activeServices.first;
          onChanged();
        });
      }
      return null;
    }, [activeServices.length]);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: activeServices.map((service) {
        final isSelected = selectedService.value?.id == service.id;
        return _ServiceChip(
          service: service,
          isSelected: isSelected,
          enabled: enabled,
          onTap: () {
            if (!enabled) return;
            selectedService.value = isSelected ? null : service;
            onChanged();
          },
        );
      }).toList(),
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
        width: 110,
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

// ── Quick add customer dialog ─────────────────────────────────────────────────

class _QuickAddCustomerDialog extends HookConsumerWidget {
  const _QuickAddCustomerDialog({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    return ScaffoldMessenger(
      child: Builder(
        builder: (innerContext) {
          Future<void> handleSave() async {
            if (!formKey.currentState!.saveAndValidate()) return;
            isSaving.value = true;
            final values = formKey.currentState!.value;

            final customerData = Customer(
              id: '',
              name: values['name'] as String,
              phone: values['phone'] as String?,
            );

            final created = await ref
                .read(customersControllerProvider.notifier)
                .createCustomer(customerData);

            isSaving.value = false;

            if (!innerContext.mounted) return;
            if (created != null) {
              Navigator.of(innerContext).pop(created);
            } else {
              showErrorSnackBar(
                innerContext,
                message: 'Failed to create customer',
                useRootMessenger: false,
              );
            }
          }

          return AlertDialog(
            title: const Text('New Customer'),
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
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => handleSave(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(innerContext).pop(),
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
          );
        },
      ),
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
  });

  final Customer customer;
  final Service service;
  final double quantity;
  final DateTime orderDate;
  final double estimatedTotal;
  final String? specialInstructions;

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

    final unitLabel = service.quantityUnit?.shortPlural ??
        (service.weightBased == true ? 'KG' : 'PCS');

    Future<void> handleThermalPrint({bool showSuccessMessage = true}) async {
      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context,
            message: 'No default printer configured', useRootMessenger: false);
        return;
      }

      isPrinting.value = true;
      final printService = ref.read(thermalPrintServiceProvider.notifier);
      final currentBranch = branchAsync.value;

      // Print customer copy (full receipt)
      final customerResult = await printService.printOrderReceipt(
        printer: printer,
        customerName: customer.name,
        serviceName: service.name,
        quantity: quantity,
        unitLabel: unitLabel,
        totalAmount: estimatedTotal,
        copyType: OrderReceiptCopy.customer,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: specialInstructions,
      );

      if (customerResult is PrintFailure) {
        isPrinting.value = false;
        if (context.mounted) {
          showErrorSnackBar(context,
              message: customerResult.message, useRootMessenger: false);
        }
        return;
      }

      // Print store copy (compact machine tag) if enabled
      if (printStoreCopy.value) {
        await Future.delayed(const Duration(milliseconds: 500));
        final storeResult = await printService.printOrderReceipt(
          printer: printer,
          customerName: customer.name,
          serviceName: service.name,
          quantity: quantity,
          unitLabel: unitLabel,
          totalAmount: estimatedTotal,
          copyType: OrderReceiptCopy.store,
          businessName: currentBranch?.name,
          branchAddress: currentBranch?.address,
          contactNumber: currentBranch?.contactNumber,
          cashierName: currentAuth?.user.name,
          specialInstructions: specialInstructions,
        );

        if (storeResult is PrintFailure) {
          isPrinting.value = false;
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: 'Customer copy printed, but store copy failed',
              useRootMessenger: false,
            );
          }
          return;
        }
      }

      isPrinting.value = false;
      if (!context.mounted) return;

      if (showSuccessMessage) {
        final msg = printStoreCopy.value
            ? 'Printed: customer copy + store copy'
            : 'Printed: customer copy';
        showSuccessSnackBar(context, message: msg, useRootMessenger: false);
      }
    }

    // Auto-print when page appears if a default printer is set
    useEffect(() {
      final printer = defaultPrinterAsync.value;
      if (printer != null && !hasAutoPrinted.value && !isPrinting.value) {
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
                child: Text('Receipt', style: theme.textTheme.titleLarge),
              ),
              if (hasDefaultPrinter)
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
              else
                TextButton(
                  onPressed: () {
                    context.pop();
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
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded,
              size: 40, color: theme.colorScheme.primary),
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
        if (hasDefaultPrinter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CheckboxListTile(
              value: printStoreCopy.value,
              onChanged: (v) => printStoreCopy.value = v ?? true,
              title: const Text('Print store copy'),
              subtitle: const Text('Prints a machine tag with customer name'),
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
            child: hasDefaultPrinter
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
