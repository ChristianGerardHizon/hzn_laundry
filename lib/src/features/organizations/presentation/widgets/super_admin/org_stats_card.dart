import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/packages/theme/feedback_colors.dart';
import '../../../domain/organization_platform_stats.dart';
import 'subscription_status_badge.dart';

/// One organization in the Super Admin list: identity, status and metrics.
class OrgStatsCard extends StatelessWidget {
  const OrgStatsCard({
    super.key,
    required this.org,
    required this.currency,
    required this.compact,
    required this.t,
    required this.onTap,
  });

  final OrganizationPlatformStats org;
  final NumberFormat currency;
  final NumberFormat compact;
  final Translations t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final letter = org.name.isNotEmpty ? org.name[0].toUpperCase() : '?';
    final status = OrgStatusStyle.from(context, t, org.subscriptionStatus);
    final hints = _footerHints(context);

    final metrics = [
      _Metric(t.organizations.metricOrders, compact.format(org.orderCount)),
      _Metric(
        t.organizations.metricCustomers,
        compact.format(org.customerCount),
      ),
      _Metric(
        t.organizations.kpiRevenue,
        currency.format(org.revenue),
        emphasised: true,
      ),
      _Metric(
        t.organizations.metricBranches,
        compact.format(org.branchCount),
      ),
      _Metric(t.organizations.metricMembers, compact.format(org.memberCount)),
    ];

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                org.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (org.slug.isNotEmpty)
                                Text(
                                  org.slug,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              if (org.packageName?.isNotEmpty == true)
                                Text(
                                  org.packageName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SubscriptionStatusBadge(style: status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MetricsRow(metrics: metrics),
                    if (hints.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: hints,
                      ),
                    ],
                  ],
                ),
              ),
              // Status accent.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(color: status.color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contextual footer items; empty when nothing needs attention.
  List<Widget> _footerHints(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final warning = FeedbackColors.warning(Theme.of(context)).icon;
    final hints = <Widget>[];
    final now = DateTime.now();

    int daysUntil(DateTime end) {
      final hours = end.toLocal().difference(now).inHours;
      return hours <= 0 ? 0 : (hours / 24).ceil();
    }

    if (org.pendingPaymentCount > 0) {
      hints.add(
        _Hint(
          icon: Icons.pending_actions_outlined,
          color: warning,
          text: t.organizations.pendingPayments(n: org.pendingPaymentCount),
        ),
      );
    }

    final raw = org.subscriptionStatus;
    if (raw == 'grace' && org.graceEndsAt != null) {
      hints.add(
        _Hint(
          icon: Icons.schedule,
          color: warning,
          text: t.organizations.graceEndsInDays(n: daysUntil(org.graceEndsAt!)),
        ),
      );
    } else if (raw == 'active' && org.periodEnd != null) {
      final days = daysUntil(org.periodEnd!);
      if (days <= 14) {
        hints.add(
          _Hint(
            icon: Icons.event_outlined,
            color: scheme.onSurfaceVariant,
            text: t.organizations.expiringInDays(n: days),
          ),
        );
      }
    }
    return hints;
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, {this.emphasised = false});

  final String label;
  final String value;
  final bool emphasised;
}

/// Five equal cells with dividers on wide cards; 3 + 2 grid when narrow.
class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 520) {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0)
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: scheme.outlineVariant,
                        ),
                      Expanded(child: _MetricCell(metric: metrics[i])),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    for (final m in metrics.take(3))
                      Expanded(child: _MetricCell(metric: m)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final m in metrics.skip(3))
                      Expanded(child: _MetricCell(metric: m)),
                    // Keep the two cells aligned with the 3-column grid above.
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              maxLines: 1,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: metric.emphasised ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
