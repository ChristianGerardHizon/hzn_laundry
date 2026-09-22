import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../subscriptions/domain/subscription_status.dart';
import '../../../subscriptions/presentation/widgets/org_subscription_sheet.dart';
import '../../domain/organization_platform_stats.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organization_platform_stats_controller.dart';
import '../widgets/super_admin_nav_panel.dart';

/// Super Admin dashboard: platform KPIs and organization list.
class SuperAdminPage extends HookConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final searchQuery = useState('');
    ref.watch(currentOrganizationControllerProvider);
    final statsAsync = ref.watch(organizationPlatformStatsControllerProvider);

    final currency = useMemoized(
      () => NumberFormat.currency(symbol: '₱', decimalDigits: 2),
    );
    final compact = useMemoized(() => NumberFormat.compact());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: _DashboardBody(
          statsAsync: statsAsync,
          searchQuery: searchQuery,
          currency: currency,
          compact: compact,
          t: t,
          scheme: scheme,
          onRefresh: () => ref
              .read(organizationPlatformStatsControllerProvider.notifier)
              .refresh(),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.statsAsync,
    required this.searchQuery,
    required this.currency,
    required this.compact,
    required this.t,
    required this.scheme,
    required this.onRefresh,
  });

  final AsyncValue<OrganizationPlatformStatsResponse> statsAsync;
  final ValueNotifier<String> searchQuery;
  final NumberFormat currency;
  final NumberFormat compact;
  final Translations t;
  final ColorScheme scheme;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: kSuperAdminBrandTeal),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState.fromError(e, onRetry: onRefresh),
        ),
      ),
      data: (data) {
        final query = searchQuery.value.trim().toLowerCase();
        final orgs = query.isEmpty
            ? data.organizations
            : data.organizations
                .where((o) => o.name.toLowerCase().contains(query))
                .toList();

        return RefreshIndicator(
          color: kSuperAdminBrandTeal,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        t.organizations.platformOverview,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _PlatformKpiGrid(
                        summary: data.summary,
                        currency: currency,
                        compact: compact,
                        t: t,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.organizations.allOrganizations,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => searchQuery.value = v,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: t.organizations.searchOrganizations,
                          hintStyle: TextStyle(
                            color: kSuperAdminMuted.withValues(alpha: 0.8),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: kSuperAdminMuted.withValues(alpha: 0.9),
                          ),
                          filled: true,
                          fillColor: kSuperAdminSurface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kSuperAdminSurfaceBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kSuperAdminSurfaceBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: kSuperAdminBrandTeal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (data.organizations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      t.organizations.noOrganizationsYet,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                )
              else if (orgs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        t.organizations.noMatchingOrganizations,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: orgs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _OrgStatsCard(
                        key: ValueKey(orgs[index].id),
                        org: orgs[index],
                        currency: currency,
                        compact: compact,
                        t: t,
                        onTap: () =>
                            showOrgSubscriptionSheet(context, orgs[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlatformKpiGrid extends StatelessWidget {
  const _PlatformKpiGrid({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final items = [
          _KpiData(
            label: t.organizations.kpiOrganizations,
            value: compact.format(summary.organizationCount),
            icon: Icons.apartment_outlined,
          ),
          _KpiData(
            label: t.organizations.kpiOrders,
            value: compact.format(summary.orderCount),
            icon: Icons.receipt_long_outlined,
          ),
          _KpiData(
            label: t.organizations.kpiCustomers,
            value: compact.format(summary.customerCount),
            icon: Icons.people_outline,
          ),
          _KpiData(
            label: t.organizations.kpiRevenue,
            value: currency.format(summary.revenue),
            icon: Icons.payments_outlined,
          ),
        ];

        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _PlatformKpiTile(data: items[i])),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _PlatformKpiTile(data: items[0])),
                const SizedBox(width: 10),
                Expanded(child: _PlatformKpiTile(data: items[1])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _PlatformKpiTile(data: items[2])),
                const SizedBox(width: 10),
                Expanded(child: _PlatformKpiTile(data: items[3])),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _PlatformKpiTile extends StatelessWidget {
  const _PlatformKpiTile({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kSuperAdminSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kSuperAdminSurfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 18, color: kSuperAdminBrandTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: kSuperAdminMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgStatsCard extends StatelessWidget {
  const _OrgStatsCard({
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
    final letter = org.name.isNotEmpty ? org.name[0].toUpperCase() : '?';
    final subStatus = org.subscriptionStatus;
    final hasSub = subStatus != null && subStatus.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kSuperAdminSurface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kSuperAdminSurfaceBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kSuperAdminBrandTeal.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: kSuperAdminBrandTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (org.slug.isNotEmpty)
                            Text(
                              org.slug,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: kSuperAdminMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (org.packageName?.isNotEmpty == true)
                            Text(
                              org.packageName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: kSuperAdminBrandTeal.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SubscriptionStatusBadge(
                      status: hasSub ? subStatus : null,
                      t: t,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip(
                      label: t.organizations.metricOrders,
                      value: compact.format(org.orderCount),
                    ),
                    _MetricChip(
                      label: t.organizations.metricCustomers,
                      value: compact.format(org.customerCount),
                    ),
                    _MetricChip(
                      label: t.organizations.kpiRevenue,
                      value: currency.format(org.revenue),
                    ),
                    _MetricChip(
                      label: t.organizations.metricBranches,
                      value: compact.format(org.branchCount),
                    ),
                    _MetricChip(
                      label: t.organizations.metricMembers,
                      value: compact.format(org.memberCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({
    required this.status,
    required this.t,
  });

  final String? status;
  final Translations t;

  @override
  Widget build(BuildContext context) {
    final parsed = status == null || status!.isEmpty
        ? null
        : SubscriptionStatus.fromString(status);
    final (label, color) = switch (parsed) {
      SubscriptionStatus.active => (
          t.subscriptions.statusActive,
          kSuperAdminBrandTeal
        ),
      SubscriptionStatus.grace => (
          t.subscriptions.statusGrace,
          Colors.orangeAccent
        ),
      SubscriptionStatus.locked => (
          t.subscriptions.statusLocked,
          Colors.redAccent
        ),
      SubscriptionStatus.cancelled => (
          t.subscriptions.statusCancelled,
          kSuperAdminMuted
        ),
      null => (t.subscriptions.noSubscription, kSuperAdminMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSuperAdminSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kSuperAdminMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
