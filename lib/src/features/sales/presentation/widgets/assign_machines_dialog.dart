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
/// one or more machines assigned. Tapping a machine selects it; long press
/// deselects. The load count per machine is computed automatically from the
/// entered weight (kg) and the machine's load rules — it is not set by tapping.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
class AssignMachinesDialog extends HookConsumerWidget {
  const AssignMachinesDialog({
    super.key,
    required this.serviceItems,
    this.initialAssignments,
    this.initialLoadCounts,
  });

  final List<SaleServiceItem> serviceItems;

  /// Pre-populated machine assignments for editing.
  /// Map of service item ID to list of machine IDs.
  final Map<String, List<String>>? initialAssignments;

  /// Pre-populated load counts for editing.
  /// Map of service item ID to (machine ID to load count).
  final Map<String, Map<String, int>>? initialLoadCounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final machinesAsync = ref.watch(machinesControllerProvider);
    // Map of service item ID to list of assigned machine IDs
    final assignments = useState<Map<String, List<String>>>(
      initialAssignments ?? {},
    );
    // Map of service item ID to (machine ID to load count)
    final loadCounts = useState<Map<String, Map<String, int>>>(
      initialLoadCounts ?? {},
    );
    final isSaving = useState(false);
    // Currently selected service item index for assignment
    final activeItemIndex = useState(0);

    Future<void> handleAssign() async {
      final repo = ref.read(salesRepositoryProvider);
      isSaving.value = true;

      final machines = machinesAsync.value ?? [];

      for (final item in serviceItems) {
        final machineIds = (assignments.value[item.id] ?? [])
            .where((id) => id.isNotEmpty)
            .toList();
        if (machineIds.isNotEmpty) {
          final counts = loadCounts.value[item.id] ?? {};
          final machineNames = machineIds
              .map((id) {
                final match = machines.where((m) => m.id == id);
                if (match.isEmpty) return '';
                final name = match.first.name;
                final count = counts[id] ?? 1;
                return count > 1 ? '$name (x$count)' : name;
              })
              .where((name) => name.isNotEmpty)
              .toList();
          final result = await repo.assignMachinesToServiceItem(
            item.id,
            machineIds,
            machineNames,
            loadCounts: counts,
          );
          if (result.isLeft()) {
            if (context.mounted) {
              isSaving.value = false;
              showErrorSnackBar(context,
                  message: 'Failed to assign machines to ${item.serviceName}',
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

                final activeItemId =
                    serviceItems[activeItemIndex.value].id;
                final activeLoadCounts =
                    loadCounts.value[activeItemId] ?? {};

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service item selector (only show if multiple)
                      if (serviceItems.length > 1) ...[
                        Text(
                          'Select service to assign machines:',
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
                                assignedCount:
                                    (assignments.value[serviceItems[i].id] ??
                                            [])
                                        .length,
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
                        selectedIds: assignments.value[activeItemId] ?? [],
                        loadCounts: activeLoadCounts,
                        disabled: isSaving.value,
                        onToggle: (machineId) {
                          final itemId =
                              serviceItems[activeItemIndex.value].id;
                          final currentAssignments =
                              Map<String, List<String>>.from(
                                  assignments.value);
                          final currentCounts =
                              Map<String, Map<String, int>>.from(
                                  loadCounts.value);
                          final list = List<String>.from(
                              currentAssignments[itemId] ?? []);
                          final counts = Map<String, int>.from(
                              currentCounts[itemId] ?? {});

                          // Select-only: tapping an unselected machine adds it
                          // with a default load of 1. The load count is driven
                          // by the weight (kg) input + machine load rules, not
                          // by repeated taps. Tapping an already-selected
                          // machine is a no-op (long-press to remove).
                          if (!list.contains(machineId)) {
                            list.add(machineId);
                            counts[machineId] = 1;
                          }

                          currentAssignments[itemId] = list;
                          currentCounts[itemId] = counts;
                          assignments.value = currentAssignments;
                          loadCounts.value = currentCounts;
                        },
                        onDeselect: (machineId) {
                          final itemId =
                              serviceItems[activeItemIndex.value].id;
                          final currentAssignments =
                              Map<String, List<String>>.from(
                                  assignments.value);
                          final currentCounts =
                              Map<String, Map<String, int>>.from(
                                  loadCounts.value);
                          final list = List<String>.from(
                              currentAssignments[itemId] ?? []);
                          final counts = Map<String, int>.from(
                              currentCounts[itemId] ?? {});

                          list.remove(machineId);
                          counts.remove(machineId);

                          currentAssignments[itemId] = list;
                          currentCounts[itemId] = counts;
                          assignments.value = currentAssignments;
                          loadCounts.value = currentCounts;
                        },
                      ),
                      // Per-machine load count steppers.
                      Builder(
                        builder: (context) {
                          final selectedIds =
                              assignments.value[activeItemId] ?? [];
                          if (selectedIds.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final selectedMachines = availableMachines
                              .where((m) => selectedIds.contains(m.id))
                              .toList();

                          void setLoad(String machineId, int load) {
                            final currentCounts =
                                Map<String, Map<String, int>>.from(
                                    loadCounts.value);
                            final counts = Map<String, int>.from(
                                currentCounts[activeItemId] ?? {});
                            counts[machineId] = load;
                            currentCounts[activeItemId] = counts;
                            loadCounts.value = currentCounts;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Text(
                                'Loads',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (final m in selectedMachines)
                                _MachineLoadRow(
                                  machine: m,
                                  loadCount: activeLoadCounts[m.id] ?? 1,
                                  disabled: isSaving.value,
                                  onChanged: (load) => setLoad(m.id, load),
                                ),
                            ],
                          );
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
    required this.assignedCount,
    required this.onTap,
  });

  final SaleServiceItem item;
  final bool isActive;
  final int assignedCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isActive,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.serviceName} (x${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'})',
          ),
          if (assignedCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$assignedCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
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
          'Tap to select, hold to remove',
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
    required this.selectedIds,
    required this.loadCounts,
    required this.disabled,
    required this.onToggle,
    required this.onDeselect,
  });

  final List<Machine> machines;
  final List<String> selectedIds;
  final Map<String, int> loadCounts;
  final bool disabled;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDeselect;

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
            selectedIds: selectedIds,
            loadCounts: loadCounts,
            disabled: disabled,
            onToggle: onToggle,
            onDeselect: onDeselect,
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
    required this.selectedIds,
    required this.loadCounts,
    required this.disabled,
    required this.onToggle,
    required this.onDeselect,
  });

  final String typeName;
  final List<Machine> machines;
  final List<String> selectedIds;
  final Map<String, int> loadCounts;
  final bool disabled;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDeselect;

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
          spacing: 10,
          runSpacing: 10,
          children: machines.map((machine) {
            final isSelected = selectedIds.contains(machine.id);
            final loadCount = loadCounts[machine.id] ?? 1;
            return _MachineChip(
              machine: machine,
              isSelected: isSelected,
              loadCount: loadCount,
              disabled: disabled,
              onTap: () => onToggle(machine.id),
              onLongPress: () => onDeselect(machine.id),
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
    required this.loadCount,
    required this.disabled,
    required this.onTap,
    required this.onLongPress,
  });

  final Machine machine;
  final bool isSelected;
  final int loadCount;
  final bool disabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

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
      child: SizedBox(
        width: 88,
        height: 88,
        child: Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: disabled ? null : onTap,
            onLongPress: disabled || !isSelected ? null : onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isInUse
                          ? theme.colorScheme.error.withValues(alpha: 0.5)
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : isInUse
                                  ? Icons.warning_amber
                                  : machine.strictSingleUse
                                      ? Icons.lock_outline
                                      : Icons.local_laundry_service,
                          size: 28,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isInUse
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            machine.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Load count badge
                  if (isSelected && loadCount > 1)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primaryContainer,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$loadCount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single selected machine's editable load count, adjusted with a stepper.
///
/// The load count is set directly by the cashier (minimum 1). There is no
/// kg/weight input or rule-based auto-computation.
class _MachineLoadRow extends StatelessWidget {
  const _MachineLoadRow({
    required this.machine,
    required this.loadCount,
    required this.disabled,
    required this.onChanged,
  });

  final Machine machine;
  final int loadCount;
  final bool disabled;

  /// Called with the new load count (always >= 1).
  final ValueChanged<int> onChanged;

  static const int _maxLoad = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrement = !disabled && loadCount > 1;
    final canIncrement = !disabled && loadCount < _maxLoad;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              machine.name,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: canDecrement ? () => onChanged(loadCount - 1) : null,
            icon: const Icon(Icons.remove),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            tooltip: 'Decrease load',
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$loadCount load${loadCount == 1 ? '' : 's'}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton.outlined(
            onPressed: canIncrement ? () => onChanged(loadCount + 1) : null,
            icon: const Icon(Icons.add),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            tooltip: 'Increase load',
          ),
        ],
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
  Map<String, List<String>>? initialAssignments,
  Map<String, Map<String, int>>? initialLoadCounts,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AssignMachinesDialog(
      serviceItems: serviceItems,
      initialAssignments: initialAssignments,
      initialLoadCounts: initialLoadCounts,
    ),
  );
}
