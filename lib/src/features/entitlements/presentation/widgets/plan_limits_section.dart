import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entitlement_limit.dart';
import '../controllers/organization_entitlements_provider.dart';

/// Read-only usage and limits (branches, employees) for an organization.
///
/// Shows `used / limit` and, when a Super Admin overrides the package value,
/// a "Set by Super Admin" chip.
class PlanLimitsSection extends ConsumerWidget {
  const PlanLimitsSection({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entitlements =
        ref.watch(organizationEntitlementsProvider(organizationId)).value;
    if (entitlements == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            'Usage & limits',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        for (final limit in entitlements.orderedLimits)
          _LimitTile(limit: limit),
      ],
    );
  }
}

class _LimitTile extends StatelessWidget {
  const _LimitTile({required this.limit});

  final EntitlementLimit limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reached = limit.isReached;
    final overridden = limit.source == LimitSource.superAdmin;

    final details = <String>[
      if (reached) 'Limit reached. Contact support to add more.',
      if (overridden && limit.note.isNotEmpty) limit.note,
    ];

    return ListTile(
      leading: Icon(
        limit.key == LimitKey.branches
            ? Icons.store_outlined
            : Icons.badge_outlined,
        color: reached ? scheme.error : scheme.primary,
      ),
      title: Text(limit.key.label),
      subtitle: details.isEmpty ? null : Text(details.join('\n')),
      isThreeLine: details.length > 1,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overridden)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'Set by Super Admin',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                backgroundColor: scheme.tertiaryContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ),
          Text(
            limit.usageLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: reached ? scheme.error : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
