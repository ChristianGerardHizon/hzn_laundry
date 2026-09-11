import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../settings/data/repositories/feature_flag_repository.dart';
import '../../../../settings/domain/feature_flag.dart';
import '../../controllers/current_organization_controller.dart';

class OrganizationFeaturesTab extends HookConsumerWidget {
  const OrganizationFeaturesTab({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final membership = ref
        .watch(currentOrganizationControllerProvider.notifier)
        .membershipFor(organizationId);
    final canManage = membership?.canManageMembers ?? false;
    final flags = useState<List<FeatureFlag>>([]);
    final isLoading = useState(true);
    final isToggling = useState(false);
    final loadError = useState<String?>(null);

    Future<void> load() async {
      isLoading.value = true;
      loadError.value = null;
      final result = await ref
          .read(featureFlagRepositoryProvider)
          .fetchAll(organizationId: organizationId);
      result.fold(
        (f) => loadError.value = f.messageString,
        (list) => flags.value = list,
      );
      isLoading.value = false;
    }

    useEffect(() {
      load();
      return null;
    }, [organizationId]);

    Future<void> handleToggle(String key, bool newValue) async {
      final flag = flags.value.where((f) => f.key == key).firstOrNull;
      if (flag == null) return;

      isToggling.value = true;
      final result = await ref
          .read(featureFlagRepositoryProvider)
          .update(flag.copyWith(enabled: newValue));
      isToggling.value = false;

      if (!context.mounted) return;
      result.fold(
        (failure) => showErrorSnackBar(
          context,
          message: 'Failed to update setting: ${failure.messageString}',
        ),
        (updated) {
          flags.value = [
            for (final f in flags.value)
              if (f.id == updated.id) updated else f,
          ];
          final currentOrgId = ref.read(currentOrganizationIdProvider);
          if (currentOrgId == organizationId) {
            ref.invalidate(organizationFeatureFlagsProvider);
            ref.invalidate(emailUpdatesEnabledProvider);
            ref.invalidate(requireMachineEnabledProvider);
            ref.invalidate(requirePackEnabledProvider);
            ref.invalidate(requireStorageEnabledProvider);
            ref.invalidate(consumableUsageEnabledProvider);
          }
          showSuccessSnackBar(
            context,
            message: newValue ? 'Setting enabled' : 'Setting disabled',
          );
        },
      );
    }

    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (loadError.value != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loadError.value!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: load, child: const Text('Retry')),
          ],
        ),
      );
    }

    FeatureFlag? flag(String key) =>
        flags.value.where((f) => f.key == key).firstOrNull;

    Widget switchTile({
      required String keyName,
      required String title,
      required IconData icon,
      required bool defaultValue,
    }) {
      final item = flag(keyName);
      final enabled = item?.enabled ?? defaultValue;
      return SwitchListTile(
        title: Text(title),
        subtitle: Text(item?.description ?? ''),
        value: enabled,
        onChanged: !canManage || isToggling.value
            ? null
            : (v) => handleToggle(keyName, v),
        secondary: Icon(
          icon,
          color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            t.organizations.featuresModules,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        switchTile(
          keyName: FeatureFlagKeys.consumableUsage,
          title: t.organizations.consumableUsage,
          icon: Icons.science_outlined,
          defaultValue: false,
        ),
        const Divider(thickness: 4, height: 32),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            t.organizations.featuresNotifications,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        switchTile(
          keyName: FeatureFlagKeys.emailUpdatesEnabled,
          title: t.organizations.sendHistoryEmails,
          icon: Icons.email_outlined,
          defaultValue: true,
        ),
        const Divider(thickness: 4, height: 32),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            t.organizations.featuresWorkflow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        switchTile(
          keyName: FeatureFlagKeys.requireMachine,
          title: t.organizations.requireMachine,
          icon: Icons.local_laundry_service,
          defaultValue: false,
        ),
        switchTile(
          keyName: FeatureFlagKeys.requirePack,
          title: t.organizations.requirePack,
          icon: Icons.shopping_bag_outlined,
          defaultValue: false,
        ),
        switchTile(
          keyName: FeatureFlagKeys.requireStorage,
          title: t.organizations.requireStorage,
          icon: Icons.inventory_2_outlined,
          defaultValue: false,
        ),
        if (!canManage)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.organizations.featuresReadOnly,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}
