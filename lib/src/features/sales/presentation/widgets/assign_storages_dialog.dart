import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../storages/domain/storage_location.dart';
import '../../../storages/presentation/controllers/storage_locations_controller.dart';

/// Dialog for assigning storage locations to sale service items.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
class AssignStoragesDialog extends HookConsumerWidget {
  const AssignStoragesDialog({
    super.key,
    required this.serviceItems,
  });

  final List<SaleServiceItem> serviceItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);
    final assignments = useState<Map<String, String?>>({});
    final isSaving = useState(false);

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
            child: storagesAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Error loading storages: $error'),
              data: (storages) {
                if (storages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No storage locations available. You can skip this step and assign storage later.',
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign a storage location to each service item:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...serviceItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ServiceItemStorageRow(
                              item: item,
                              storages: storages,
                              selectedStorageId: assignments.value[item.id],
                              onChanged: isSaving.value
                                  ? null
                                  : (storageId) {
                                      final newAssignments =
                                          Map<String, String?>.from(
                                              assignments.value);
                                      newAssignments[item.id] = storageId;
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

class _ServiceItemStorageRow extends StatelessWidget {
  const _ServiceItemStorageRow({
    required this.item,
    required this.storages,
    required this.selectedStorageId,
    required this.onChanged,
  });

  final SaleServiceItem item;
  final List<StorageLocation> storages;
  final String? selectedStorageId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.serviceName} (x${item.quantity})',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedStorageId,
          decoration: const InputDecoration(
            hintText: 'Select storage location',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('None'),
            ),
            ...storages.where((s) => s.isAvailable).map((storage) {
              return DropdownMenuItem<String>(
                value: storage.id,
                child: Text(storage.name),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Shows the assign storages dialog.
///
/// Returns `true` if assignments were made or skipped, `null` if cancelled.
Future<bool?> showAssignStoragesDialog(
  BuildContext context, {
  required List<SaleServiceItem> serviceItems,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AssignStoragesDialog(serviceItems: serviceItems),
  );
}
