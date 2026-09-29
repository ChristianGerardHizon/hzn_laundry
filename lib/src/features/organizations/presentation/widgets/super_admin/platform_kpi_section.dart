import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../domain/organization_platform_stats.dart';
import '../super_admin_theme.dart';

/// Platform KPIs: revenue as the hero figure plus three secondary tiles.
class PlatformKpiSection extends StatelessWidget {
  const PlatformKpiSection({
    super.key,
    required this.summary,
    required this.currency,
    required this.compact,
    required this.t,
  });

  final OrganizationPlatformSummary summary;
  final NumberFormat currency;
  final NumberFormat compact;
  final Translations t;

  @override
  Widget build(BuildContext context) {
    final hero = _RevenueHero(
      label: t.organizations.kpiRevenue,
      value: currency.format(summary.revenue),
    );
    final tiles = [
      _KpiTile(
        label: t.organizations.kpiOrganizations,
        value: compact.format(summary.organizationCount),
        icon: Icons.apartment_outlined,
      ),
      _KpiTile(
        label: t.organizations.kpiOrders,
        value: compact.format(summary.orderCount),
        icon: Icons.receipt_long_outlined,
      ),
      _KpiTile(
        label: t.organizations.kpiCustomers,
        value: compact.format(summary.customerCount),
        icon: Icons.people_outline,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;

        if (wide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: hero),
                for (final tile in tiles) ...[
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: tile),
                ],
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            hero,
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: tiles[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RevenueHero extends StatelessWidget {
  const _RevenueHero({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$label $value',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kSuperAdminBrandTeal.withValues(alpha: 0.22),
              kSuperAdminSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kSuperAdminBrandTeal.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: kSuperAdminBrandTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: kSuperAdminMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$label $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kSuperAdminSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kSuperAdminSurfaceBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: kSuperAdminBrandTeal),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: kSuperAdminMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
