import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../machines/domain/machine.dart';
import '../../../machines/presentation/controllers/machine_usage_provider.dart';
import '../../../machines/presentation/controllers/machines_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../services/domain/sale_service_item.dart';

/// Dialog for assigning machines to sale service items.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
class AssignMachinesDialog extends HookConsumerWidget {
  const AssignMachinesDialog({
    super.key,
    required this.serviceItems,
  });

  final List<SaleServiceItem> serviceItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final machinesAsync = ref.watch(machinesControllerProvider);
    final assignments = useState<Map<String, String?>>({});
    final isSaving = useState(false);

    Future<void> handleAssign() async {
      final repo = ref.read(salesRepositoryProvider);
      isSaving.value = true;

      final machines = machinesAsync.value ?? [];

      for (final item in serviceItems) {
        final machineId = assignments.value[item.id];
        if (machineId != null && machineId.isNotEmpty) {
          final machine = machines.firstWhere((m) => m.id == machineId);
          final result = await repo.assignMachineToServiceItem(
            item.id,
            machineId,
            machine.name,
          );
          if (result.isLeft()) {
            if (context.mounted) {
              isSaving.value = false;
              showErrorSnackBar(context,
                  message: 'Failed to assign machine to ${item.serviceName}',
                  useRootMessenger: false);
              return;
            }
          }
        }
      }

      isSaving.value = false;
      if (context.mounted) {
        context.pop(true);
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: const Text('Assign Machines'),
          content: SizedBox(
            width: 400,
            child: machinesAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Error loading machines: $error'),
              data: (machines) {
                if (machines.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No machines available. You can skip this step and assign machines later.',
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign a machine to each service item:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...serviceItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ServiceItemMachineRow(
                              item: item,
                              machines: machines,
                              selectedMachineId: assignments.value[item.id],
                              onChanged: isSaving.value
                                  ? null
                                  : (machineId) {
                                      final newAssignments =
                                          Map<String, String?>.from(
                                              assignments.value);
                                      newAssignments[item.id] = machineId;
                                      assignments.value = newAssignments;
                                    },
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(true),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : handleAssign,
              child: isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Assign & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItemMachineRow extends HookConsumerWidget {
  const _ServiceItemMachineRow({
    required this.item,
    required this.machines,
    required this.selectedMachineId,
    required this.onChanged,
  });

  final SaleServiceItem item;
  final List<Machine> machines;
  final String? selectedMachineId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Find the selected machine to check strictSingleUse
    final selectedMachine = selectedMachineId != null && selectedMachineId!.isNotEmpty
        ? machines.where((m) => m.id == selectedMachineId).firstOrNull
        : null;

    // Only watch usage if the selected machine has strictSingleUse enabled
    final usageAsync = selectedMachine?.strictSingleUse == true
        ? ref.watch(machineUsageProvider(selectedMachineId!))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.serviceName} (x${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'})',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedMachineId,
          decoration: const InputDecoration(
            hintText: 'Select machine',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('None'),
            ),
            ...machines.where((m) => m.isAvailable).map((machine) {
              return DropdownMenuItem<String>(
                value: machine.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (machine.strictSingleUse) ...[
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        '${machine.name} (${machine.type.displayName})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
        // Show warning if strictSingleUse machine is in use
        if (usageAsync != null)
          usageAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (usage) {
              if (!usage.isInUse) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Machine is processing ${usage.displaySummary}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Shows the assign machines dialog.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
Future<bool?> showAssignMachinesDialog(
  BuildContext context, {
  required List<SaleServiceItem> serviceItems,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AssignMachinesDialog(serviceItems: serviceItems),
  );
}
