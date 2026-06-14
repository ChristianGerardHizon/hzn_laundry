import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/feature_flag_repository.dart';
import '../../domain/feature_flag.dart';
import '../../../../core/widgets/form_feedback.dart';

class EmailSettingsPanel extends HookConsumerWidget {
  const EmailSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allFlagsAsync = ref.watch(_featureFlagsListProvider);
    final isToggling = useState(false);

    Future<void> handleToggle(String key, bool newValue, {
      VoidCallback? onInvalidate,
    }) async {
      final flags = allFlagsAsync.value;
      if (flags == null) return;

      final flag = flags.where((f) => f.key == key).firstOrNull;
      if (flag == null) return;

      isToggling.value = true;
      final repo = ref.read(featureFlagRepositoryProvider);
      final result = await repo.update(flag.copyWith(enabled: newValue));
      isToggling.value = false;

      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: 'Failed to update setting: ${failure.messageString}',
            );
          }
        },
        (_) {
          onInvalidate?.call();
          ref.invalidate(_featureFlagsListProvider);
          if (context.mounted) {
            showSuccessSnackBar(
              context,
              message: newValue ? 'Setting enabled' : 'Setting disabled',
            );
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: allFlagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_featureFlagsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (flags) {
          FeatureFlag? flag(String key) =>
              flags.where((f) => f.key == key).firstOrNull;

          final emailFlag = flag('emailUpdatesEnabled');
          final requireMachineFlag = flag('requireMachine');
          final requirePackFlag = flag('requirePack');
          final requireStorageFlag = flag('requireStorage');

          return ListView(
            children: [
              // Notifications
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Notifications',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Send order history emails'),
                subtitle: Text(
                  emailFlag?.description ??
                      'Send order history link emails to customers',
                ),
                value: emailFlag?.enabled ?? true,
                onChanged: isToggling.value
                    ? null
                    : (v) => handleToggle(
                          'emailUpdatesEnabled',
                          v,
                          onInvalidate: () => ref.invalidate(emailUpdatesEnabledProvider),
                        ),
                secondary: Icon(
                  (emailFlag?.enabled ?? true)
                      ? Icons.email
                      : Icons.email_outlined,
                  color: (emailFlag?.enabled ?? true)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'When enabled, customers with an email address on file receive '
                  'an order history link after each order.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),

              // Order Workflow
              const Divider(thickness: 4, height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Order Workflow',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Require machine assignment'),
                subtitle: Text(
                  requireMachineFlag?.description ??
                      'Block moving to Processing if no machine is assigned',
                ),
                value: requireMachineFlag?.enabled ?? false,
                onChanged: isToggling.value
                    ? null
                    : (v) => handleToggle(
                          'requireMachine',
                          v,
                          onInvalidate: () => ref.invalidate(requireMachineEnabledProvider),
                        ),
                secondary: Icon(
                  Icons.local_laundry_service,
                  color: (requireMachineFlag?.enabled ?? false)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              SwitchListTile(
                title: const Text('Require pack count'),
                subtitle: Text(
                  requirePackFlag?.description ??
                      'Block moving to Ready if no packs are set on the order',
                ),
                value: requirePackFlag?.enabled ?? false,
                onChanged: isToggling.value
                    ? null
                    : (v) => handleToggle(
                          'requirePack',
                          v,
                          onInvalidate: () => ref.invalidate(requirePackEnabledProvider),
                        ),
                secondary: Icon(
                  Icons.shopping_bag_outlined,
                  color: (requirePackFlag?.enabled ?? false)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              SwitchListTile(
                title: const Text('Require storage assignment'),
                subtitle: Text(
                  requireStorageFlag?.description ??
                      'Block moving to Ready if no storage location is assigned',
                ),
                value: requireStorageFlag?.enabled ?? false,
                onChanged: isToggling.value
                    ? null
                    : (v) => handleToggle(
                          'requireStorage',
                          v,
                          onInvalidate: () => ref.invalidate(requireStorageEnabledProvider),
                        ),
                secondary: Icon(
                  Icons.inventory_2_outlined,
                  color: (requireStorageFlag?.enabled ?? false)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'When enabled, these rules block order status transitions '
                  'until the required information is recorded.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Internal provider to watch the full flags list for toggling.
final _featureFlagsListProvider = FutureProvider.autoDispose(
  (ref) async {
    final repo = ref.watch(featureFlagRepositoryProvider);
    final result = await repo.fetchAll();
    return result.fold((_) => [], (flags) => flags);
  },
);
