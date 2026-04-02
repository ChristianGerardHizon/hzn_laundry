import 'package:flutter/material.dart';
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
  });

  final String saleId;
  final List<SaleServiceItem> serviceItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);
    // Map of service item ID to assigned storage ID
    final assignments = useState<Map<String, String?>>({});
    final selectedPacks = useState<int?>(null);
    final isSaving = useState(false);
    // Currently selected service item index for assignment
    final activeItemIndex = useState(0);

    Future<void> handleAssign() async {
      final repo = ref.read(salesRepositoryProvider);
      isSaving.value = true;

      final storages = storagesAsync.value ?? [];

      for (final item in serviceItems) {
        final storageId = assignments.value[item.id];
        if (storageId != null && storageId.isNotEmpty) {
          final storage = storages.firstWhere((s) => s.id == storageId);
          final result = await repo.assignStorageToServiceItem(
            item.id,
            storageId,
            storage.name,
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
                                      hasAssignment: assignments
                                              .value[serviceItems[i].id] !=
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
                            // Storage grid - tappable chips
                            _StorageGrid(
                              storages: availableStorages,
                              selectedId: assignments.value[
                                  serviceItems[activeItemIndex.value].id],
                              disabled: isSaving.value,
                              onToggle: (storageId) {
                                final itemId =
                                    serviceItems[activeItemIndex.value].id;
                                final current = Map<String, String?>.from(
                                    assignments.value);

                                // Toggle: deselect if already selected
                                if (current[itemId] == storageId) {
                                  current[itemId] = null;
                                } else {
                                  current[itemId] = storageId;
                                }

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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 2, 3, 4, 5].map((value) {
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
                    }).toList(),
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
          'Tap to select location',
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
    required this.selectedId,
    required this.disabled,
    required this.onToggle,
  });

  final List<StorageLocation> storages;
  final String? selectedId;
  final bool disabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: storages.map((storage) {
        final isSelected = selectedId == storage.id;
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

    return Material(
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
              Text(
                storage.name,
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
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AssignStoragesDialog(
      saleId: saleId,
      serviceItems: serviceItems,
    ),
  );
}
