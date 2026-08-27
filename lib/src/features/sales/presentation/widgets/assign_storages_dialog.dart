import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../storages/domain/storage_location.dart';
import '../../../storages/presentation/controllers/storage_locations_controller.dart';

/// Dialog for assigning storage locations to sale service items
/// and setting the number of packs (laundry bags).
///
/// Shows tappable storage chips. Each service item can have one storage
/// assigned. Users tap a service item, then tap a storage to assign.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
class AssignStoragesDialog extends HookConsumerWidget {
  const AssignStoragesDialog({
    super.key,
    required this.saleId,
    required this.serviceItems,
    this.initialAssignments,
    this.initialPacks,
    this.requirePacks = false,
  });

  final String saleId;
  final List<SaleServiceItem> serviceItems;

  /// Pre-populated storage assignments for editing.
  /// Map of service item ID to list of storage IDs.
  final Map<String, List<String>>? initialAssignments;

  /// Pre-populated packs count for editing.
  final int? initialPacks;

  /// When true, Skip is hidden and a pack count greater than 0 is required.
  final bool requirePacks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);
    // Map of service item ID to assigned storage IDs (multi-select)
    final assignments = useState<Map<String, List<String>>>(
      initialAssignments ?? {},
    );
    final selectedPacks = useState<int?>(initialPacks);
    final isCustomPacksMode = useState(
      initialPacks != null &&
          ![1, 2, 3, 4, 5, 6, 7, 8].contains(initialPacks),
    );
    final customPacksController = useTextEditingController(
      text: isCustomPacksMode.value ? '$initialPacks' : '',
    );
    final isSaving = useState(false);
    // Currently selected service item index for assignment
    final activeItemIndex = useState(0);

    Future<void> handleAssign() async {
      final packs = selectedPacks.value ?? 0;
      if (requirePacks && packs <= 0) {
        showErrorSnackBar(
          context,
          message: 'Set the number of packs before continuing.',
          useRootMessenger: false,
        );
        return;
      }

      final repo = ref.read(salesRepositoryProvider);
      isSaving.value = true;

      final storages = storagesAsync.value ?? [];

      for (final item in serviceItems) {
        final storageIdList = assignments.value[item.id];
        if (storageIdList != null && storageIdList.isNotEmpty) {
          // Filter out empty IDs and safely look up names
          final validIds =
              storageIdList.where((id) => id.isNotEmpty).toList();
          if (validIds.isEmpty) continue;
          final storageNames = validIds
              .map((id) {
                final match = storages.where((s) => s.id == id);
                return match.isNotEmpty ? match.first.name : '';
              })
              .where((name) => name.isNotEmpty)
              .toList();
          final result = await repo.assignStoragesToServiceItem(
            item.id,
            validIds,
            storageNames,
          );
          if (result.isLeft()) {
            if (context.mounted) {
              isSaving.value = false;
              showErrorSnackBar(context,
                  message: 'Failed to assign storage to ${item.serviceName}',
                  useRootMessenger: false);
              return;
            }
          }
        }
      }

      // Save packs count
      if (selectedPacks.value != null && selectedPacks.value! > 0) {
        await repo.updateSale(saleId, {'packs': selectedPacks.value});
      }

      isSaving.value = false;
      if (context.mounted) {
        context.pop(true);
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: const Text('Assign Storage Locations'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Storage assignments
                  if (serviceItems.isNotEmpty)
                    storagesAsync.when(
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) =>
                          Text('Error loading storages: $error'),
                      data: (storages) {
                        if (storages.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No storage locations available. You can skip this step and assign storage later.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final availableStorages =
                            storages.where((s) => s.isAvailable).toList();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service item selector (only show if multiple)
                            if (serviceItems.length > 1) ...[
                              Text(
                                'Select service to assign a location:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  for (int i = 0;
                                      i < serviceItems.length;
                                      i++)
                                    _ServiceItemChip(
                                      item: serviceItems[i],
                                      isActive: activeItemIndex.value == i,
                                      hasAssignment: (assignments
                                                  .value[serviceItems[i].id] ??
                                              [])
                                          .isNotEmpty,
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
                            // Storage grid - tappable chips
                            _StorageGrid(
                              storages: availableStorages,
                              selectedIds: assignments.value[
                                      serviceItems[activeItemIndex.value].id] ??
                                  [],
                              disabled: isSaving.value,
                              onToggle: (storageId) {
                                final itemId =
                                    serviceItems[activeItemIndex.value].id;
                                final current =
                                    Map<String, List<String>>.from(
                                        assignments.value);
                                final list =
                                    List<String>.from(current[itemId] ?? []);

                                // Toggle: remove if already selected, add if not
                                if (list.contains(storageId)) {
                                  list.remove(storageId);
                                } else {
                                  list.add(storageId);
                                }

                                current[itemId] = list;
                                assignments.value = current;
                              },
                            ),
                          ],
                        );
                      },
                    ),

                  // Packs (laundry bags) picker
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Number of Packs',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How many laundry bags were used?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isCustomPacksMode.value)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...[1, 2, 3, 4, 5, 6, 7, 8].map((value) {
                          final isSelected = selectedPacks.value == value;
                          return ChoiceChip(
                            label: Text('$value'),
                            selected: isSelected,
                            onSelected: isSaving.value
                                ? null
                                : (_) => selectedPacks.value = value,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                            selectedColor: theme.colorScheme.primary,
                          );
                        }),
                        ActionChip(
                          label: const Text('Custom'),
                          avatar: const Icon(Icons.edit, size: 16),
                          onPressed: isSaving.value
                              ? null
                              : () {
                                  isCustomPacksMode.value = true;
                                  selectedPacks.value = null;
                                },
                        ),
                      ],
                    )
                  else
                    TextField(
                      controller: customPacksController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Number of packs',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.grid_view, size: 20),
                          tooltip: 'Show presets',
                          onPressed: isSaving.value
                              ? null
                              : () {
                                  isCustomPacksMode.value = false;
                                  selectedPacks.value = null;
                                },
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        selectedPacks.value =
                            (parsed != null && parsed > 0) ? parsed : null;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(null),
              child: const Text('Cancel'),
            ),
            if (!requirePacks)
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
      avatar: hasAssignment ? const Icon(Icons.check_circle, size: 18) : null,
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
          Icons.inventory_2_outlined,
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
          'Tap to select locations',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StorageGrid extends StatelessWidget {
  const _StorageGrid({
    required this.storages,
    required this.selectedIds,
    required this.disabled,
    required this.onToggle,
  });

  final List<StorageLocation> storages;
  final List<String> selectedIds;
  final bool disabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: storages.map((storage) {
        final isSelected = selectedIds.contains(storage.id);
        return _StorageChip(
          storage: storage,
          isSelected: isSelected,
          disabled: disabled,
          onTap: () => onToggle(storage.id),
        );
      }).toList(),
    );
  }
}

class _StorageChip extends StatelessWidget {
  const _StorageChip({
    required this.storage,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
  });

  final StorageLocation storage;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 88,
      height: 88,
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.shelves,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    storage.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
        ),
      ),
    );
  }
}

/// Shows the assign storages dialog.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
Future<bool?> showAssignStoragesDialog(
  BuildContext context, {
  required String saleId,
  required List<SaleServiceItem> serviceItems,
  Map<String, List<String>>? initialAssignments,
  int? initialPacks,
  bool requirePacks = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AssignStoragesDialog(
      saleId: saleId,
      serviceItems: serviceItems,
      initialAssignments: initialAssignments,
      initialPacks: initialPacks,
      requirePacks: requirePacks,
    ),
  );
}
