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
/// Shows tappable machine chips grouped by type. Each service item can have
/// one machine assigned. Users tap a service item, then tap a machine to assign.
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
    // Map of service item ID to assigned machine ID
    final assignments = useState<Map<String, String?>>({});
    final isSaving = useState(false);
    // Currently selected service item index for assignment
    final activeItemIndex = useState(0);

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

                final availableMachines =
                    machines.where((m) => m.isAvailable).toList();

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service item selector (only show if multiple)
                      if (serviceItems.length > 1) ...[
                        Text(
                          'Select service to assign a machine:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (int i = 0; i < serviceItems.length; i++)
                              _ServiceItemChip(
                                item: serviceItems[i],
                                isActive: activeItemIndex.value == i,
                                hasAssignment:
                                    assignments.value[serviceItems[i].id] !=
                                        null,
                                onTap: isSaving.value
                                    ? null
                                    : () => activeItemIndex.value = i,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                      ],
                      // Current service item label
                      _ActiveServiceLabel(
                        item: serviceItems[activeItemIndex.value],
                      ),
                      const SizedBox(height: 12),
                      // Machine grid - tappable chips
                      _MachineGrid(
                        machines: availableMachines,
                        selectedId: assignments
                            .value[serviceItems[activeItemIndex.value].id],
                        disabled: isSaving.value,
                        onToggle: (machineId) {
                          final itemId =
                              serviceItems[activeItemIndex.value].id;
                          final current = Map<String, String?>.from(
                              assignments.value);

                          // Toggle: deselect if already selected, else select
                          if (current[itemId] == machineId) {
                            current[itemId] = null;
                          } else {
                            current[itemId] = machineId;
                          }

                          assignments.value = current;
                        },
                      ),
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

class _ServiceItemChip extends StatelessWidget {
  const _ServiceItemChip({
    required this.item,
    required this.isActive,
    required this.hasAssignment,
    required this.onTap,
  });

  final SaleServiceItem item;
  final bool isActive;
  final bool hasAssignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isActive,
      avatar: hasAssignment
          ? const Icon(Icons.check_circle, size: 18)
          : null,
      label: Text(
        '${item.serviceName} (x${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'})',
      ),
      onSelected: onTap != null ? (_) => onTap!() : null,
    );
  }
}

class _ActiveServiceLabel extends StatelessWidget {
  const _ActiveServiceLabel({required this.item});

  final SaleServiceItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.local_laundry_service,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          '${item.serviceName} (x${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          'Tap to select machines',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MachineGrid extends StatelessWidget {
  const _MachineGrid({
    required this.machines,
    required this.selectedId,
    required this.disabled,
    required this.onToggle,
  });

  final List<Machine> machines;
  final String? selectedId;
  final bool disabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    // Group machines by type
    final grouped = <String, List<Machine>>{};
    for (final machine in machines) {
      final key = machine.type.displayName;
      grouped.putIfAbsent(key, () => []).add(machine);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          _MachineTypeSection(
            typeName: entry.key,
            machines: entry.value,
            selectedId: selectedId,
            disabled: disabled,
            onToggle: onToggle,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MachineTypeSection extends StatelessWidget {
  const _MachineTypeSection({
    required this.typeName,
    required this.machines,
    required this.selectedId,
    required this.disabled,
    required this.onToggle,
  });

  final String typeName;
  final List<Machine> machines;
  final String? selectedId;
  final bool disabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          typeName,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: machines.map((machine) {
            final isSelected = selectedId == machine.id;
            return _MachineChip(
              machine: machine,
              isSelected: isSelected,
              disabled: disabled,
              onTap: () => onToggle(machine.id),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MachineChip extends HookConsumerWidget {
  const _MachineChip({
    required this.machine,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
  });

  final Machine machine;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Only check usage for strictSingleUse machines
    final usageAsync = machine.strictSingleUse
        ? ref.watch(machineUsageProvider(machine.id))
        : null;

    final isInUse = usageAsync?.value?.isInUse ?? false;
    final usageInfo = usageAsync?.value;

    return Tooltip(
      message: isInUse && usageInfo != null
          ? 'Processing ${usageInfo.displaySummary}'
          : '',
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isInUse
                        ? theme.colorScheme.error.withValues(alpha: 0.5)
                        : Colors.transparent,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                ],
                if (isInUse && !isSelected) ...[
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                ],
                if (machine.strictSingleUse && !isSelected && !isInUse) ...[
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  machine.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
