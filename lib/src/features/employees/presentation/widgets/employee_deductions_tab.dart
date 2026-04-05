import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/deduction_type.dart';
import '../../domain/deduction_value_type.dart';
import '../../domain/employee_deduction.dart';
import '../controllers/employee_deductions_controller.dart';
import 'deduction_form_dialog.dart';

/// Tab showing deductions list for a specific employee.
class EmployeeDeductionsTab extends ConsumerWidget {
  const EmployeeDeductionsTab({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  static final _monthYearFormat = DateFormat('MMM yyyy');
  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deductionsAsync =
        ref.watch(employeeDeductionsControllerProvider(employeeId));
    final theme = Theme.of(context);

    return Scaffold(
      body: deductionsAsync.when(
        data: (deductions) {
          if (deductions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.money_off,
                    size: 48,
                    color:
                        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No deductions yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a deduction',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Separate active and inactive
          final active = deductions.where((d) => d.isActive).toList();
          final inactive = deductions.where((d) => !d.isActive).toList();

          return RefreshIndicator(
            onRefresh: () => ref
                .read(
                    employeeDeductionsControllerProvider(employeeId).notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isNotEmpty) ...[
                  Text(
                    'Active Deductions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...active.map((d) => _DeductionCard(
                        deduction: d,
                        employeeId: employeeId,
                      )),
                ],
                if (inactive.isNotEmpty) ...[
                  if (active.isNotEmpty) const SizedBox(height: 16),
                  Text(
                    'Inactive Deductions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...inactive.map((d) => _DeductionCard(
                        deduction: d,
                        employeeId: employeeId,
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDeductionFormDialog(context, employeeId: employeeId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DeductionCard extends ConsumerWidget {
  const _DeductionCard({
    required this.deduction,
    required this.employeeId,
  });

  final EmployeeDeduction deduction;
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = deduction.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type icon
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isActive
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    _iconForType(deduction.type),
                    size: 18,
                    color: isActive
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deduction.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? null
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _valueDisplay(deduction),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value
                Text(
                  _amountDisplay(deduction),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handleAction(context, ref, action),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: isActive ? 'deactivate' : 'activate',
                      child: ListTile(
                        leading: Icon(
                          isActive ? Icons.pause_circle : Icons.play_circle,
                        ),
                        title: Text(isActive ? 'Deactivate' : 'Activate'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
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
            const SizedBox(height: 8),
            // Duration row
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _durationDisplay(deduction),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Inactive',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(DeductionType deductionType) {
    return switch (deductionType) {
      DeductionType.cashAdvance => Icons.money,
      DeductionType.sss => Icons.shield,
      DeductionType.philHealth => Icons.local_hospital,
      DeductionType.pagIbig => Icons.home,
      DeductionType.other => Icons.receipt_long,
    };
  }

  String _valueDisplay(EmployeeDeduction d) {
    if (d.valueType == DeductionValueType.percentage) {
      return '${d.value}% of base salary';
    }
    return 'Fixed amount';
  }

  String _amountDisplay(EmployeeDeduction d) {
    if (d.valueType == DeductionValueType.percentage) {
      return '${d.value}%';
    }
    return EmployeeDeductionsTab._currencyFormat.format(d.value);
  }

  String _durationDisplay(EmployeeDeduction d) {
    final format = EmployeeDeductionsTab._monthYearFormat;

    if (d.startMonth == null && d.endMonth == null) {
      return 'Lifetime';
    }

    final start =
        d.startMonth != null ? format.format(d.startMonth!) : 'Start';
    final end = d.endMonth != null ? format.format(d.endMonth!) : 'Ongoing';

    return '$start — $end';
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final controller = ref.read(
      employeeDeductionsControllerProvider(employeeId).notifier,
    );

    switch (action) {
      case 'edit':
        showDeductionFormDialog(
          context,
          employeeId: employeeId,
          deduction: deduction,
        );
      case 'activate':
      case 'deactivate':
        final newActive = action == 'activate';
        final success = await controller.updateDeduction(
          id: deduction.id,
          type: deduction.type,
          valueType: deduction.valueType,
          value: deduction.value,
          name: deduction.name,
          startMonth: deduction.startMonth,
          endMonth: deduction.endMonth,
          isActive: newActive,
        );
        if (success && context.mounted) {
          showSuccessSnackBar(
            context,
            message: newActive
                ? 'Deduction activated'
                : 'Deduction deactivated',
          );
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Deduction'),
            content: Text(
              'Are you sure you want to delete the "${deduction.displayName}" deduction?',
            ),
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

        if (confirmed == true) {
          final success = await controller.deleteDeduction(deduction.id);
          if (success && context.mounted) {
            showSuccessSnackBar(context, message: 'Deduction deleted');
          } else if (context.mounted) {
            showErrorSnackBar(
              context,
              message: 'Failed to delete deduction',
            );
          }
        }
    }
  }
}
