import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/feature_entitlement.dart';
import '../controllers/organization_entitlements_provider.dart';

/// Read-only list of an organization's feature entitlements.
///
/// Shows each feature's resolved state and where it came from: the
/// subscription plan, or a Super Admin override (enabled / disabled).
class PlanFeaturesSection extends ConsumerWidget {
  const PlanFeaturesSection({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(organizationEntitlementsProvider(organizationId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(child: Text('Could not load plan features.')),
            TextButton(
              onPressed: () => ref
                  .invalidate(organizationEntitlementsProvider(organizationId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (entitlements) {
        final planLabel = entitlements.packageName.isEmpty
            ? 'your plan'
            : entitlements.packageName;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Plan features',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                entitlements.hasSubscription
                    ? 'Features available on $planLabel. Contact support to '
                        'change what is enabled.'
                    : 'Features available for this organization.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            for (final item in entitlements.ordered)
              _FeatureTile(item: item, planLabel: planLabel),
          ],
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.item, required this.planLabel});

  final FeatureEntitlement item;
  final String planLabel;

  String _statusLabel() {
    switch (item.source) {
      case EntitlementSource.superAdminEnabled:
        return 'Enabled by Super Admin';
      case EntitlementSource.superAdminDisabled:
        return 'Disabled by Super Admin';
      case EntitlementSource.notInPlan:
        return 'Not in $planLabel';
      case EntitlementSource.plan:
        return item.enabled ? 'Included in $planLabel' : 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final feature = item.feature;

    final Color chipColor;
    final Color chipTextColor;
    if (item.source == EntitlementSource.superAdminEnabled) {
      chipColor = scheme.tertiaryContainer;
      chipTextColor = scheme.onTertiaryContainer;
    } else if (item.source == EntitlementSource.superAdminDisabled) {
      chipColor = scheme.errorContainer;
      chipTextColor = scheme.onErrorContainer;
    } else if (item.enabled) {
      chipColor = scheme.secondaryContainer;
      chipTextColor = scheme.onSecondaryContainer;
    } else {
      chipColor = scheme.surfaceContainerHighest;
      chipTextColor = scheme.onSurfaceVariant;
    }

    final details = <String>[
      feature.description,
      if (item.blockedBy != null)
        'Requires ${item.blockedBy!.label}, which is off.',
      if (item.source.isOverride && item.note.isNotEmpty) item.note,
    ];

    return ListTile(
      leading: Icon(
        item.enabled ? Icons.check_circle : Icons.remove_circle_outline,
        color: item.enabled ? scheme.primary : scheme.outline,
      ),
      title: Text(feature.label),
      subtitle: Text(details.join('\n')),
      isThreeLine: details.length > 1,
      trailing: Chip(
        label: Text(
          _statusLabel(),
          style: theme.textTheme.labelSmall?.copyWith(color: chipTextColor),
        ),
        backgroundColor: chipColor,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
