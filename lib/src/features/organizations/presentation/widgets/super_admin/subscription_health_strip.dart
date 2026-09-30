import 'package:flutter/material.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../domain/organization_list_filter.dart';
import '../super_admin_theme.dart';
import 'subscription_status_badge.dart';

/// Tappable summary of organizations per subscription bucket.
///
/// Tapping a bucket applies it as the list filter; tapping the active bucket
/// again clears it.
class SubscriptionHealthStrip extends StatelessWidget {
  const SubscriptionHealthStrip({
    super.key,
    required this.counts,
    required this.selected,
    required this.onSelected,
    required this.t,
  });

  final Map<OrgStatusFilter, int> counts;
  final OrgStatusFilter selected;
  final ValueChanged<OrgStatusFilter> onSelected;
  final Translations t;

  static const _buckets = [
    OrgStatusFilter.active,
    OrgStatusFilter.grace,
    OrgStatusFilter.locked,
    OrgStatusFilter.other,
  ];

  OrgStatusStyle _style(OrgStatusFilter bucket) => switch (bucket) {
        OrgStatusFilter.active => OrgStatusStyle.from(t, 'active'),
        OrgStatusFilter.grace => OrgStatusStyle.from(t, 'grace'),
        OrgStatusFilter.locked => OrgStatusStyle.from(t, 'locked'),
        _ => OrgStatusStyle(
            label: t.organizations.filterOther,
            color: kSuperAdminMuted,
            icon: Icons.remove_circle_outline,
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.organizations.subscriptionHealth,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: kSuperAdminMuted,
              ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _buckets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _HealthItem(
                    style: _style(_buckets[i]),
                    count: counts[_buckets[i]] ?? 0,
                    isSelected: selected == _buckets[i],
                    onTap: () => onSelected(
                      selected == _buckets[i]
                          ? OrgStatusFilter.all
                          : _buckets[i],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthItem extends StatelessWidget {
  const _HealthItem({
    required this.style,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final OrgStatusStyle style;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${style.label} $count',
      excludeSemantics: true,
      child: Material(
        color: isSelected
            ? style.color.withValues(alpha: 0.14)
            : kSuperAdminSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? style.color : kSuperAdminSurfaceBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            constraints: const BoxConstraints(minHeight: kSuperAdminMinTap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(style.icon, size: 14, color: style.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        style.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: kSuperAdminMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? style.color : Colors.white,
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
