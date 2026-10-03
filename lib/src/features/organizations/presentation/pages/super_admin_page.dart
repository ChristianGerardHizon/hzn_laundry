import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../subscriptions/presentation/widgets/org_subscription_sheet.dart';
import '../../domain/organization_list_filter.dart';
import '../../domain/organization_platform_stats.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organization_platform_stats_controller.dart';
import '../widgets/super_admin/org_list_toolbar.dart';
import '../widgets/super_admin/org_stats_card.dart';
import '../widgets/super_admin/platform_kpi_section.dart';
import '../widgets/super_admin/subscription_health_strip.dart';
import '../widgets/super_admin_theme.dart';

/// Super Admin dashboard: platform KPIs and organization list.
class SuperAdminPage extends HookConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final searchQuery = useState('');
    final statusFilter = useState(OrgStatusFilter.all);
    final sortKey = useState(OrgSortKey.revenue);
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
          statusFilter: statusFilter,
          sortKey: sortKey,
          currency: currency,
          compact: compact,
          t: t,
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
    required this.statusFilter,
    required this.sortKey,
    required this.currency,
    required this.compact,
    required this.t,
    required this.onRefresh,
  });

  final AsyncValue<OrganizationPlatformStatsResponse> statsAsync;
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<OrgStatusFilter> statusFilter;
  final ValueNotifier<OrgSortKey> sortKey;
  final NumberFormat currency;
  final NumberFormat compact;
  final Translations t;
  final Future<void> Function() onRefresh;

  void _clearFilters() {
    searchQuery.value = '';
    statusFilter.value = OrgStatusFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return statsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: scheme.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState.fromError(e, onRetry: onRefresh),
        ),
      ),
      data: (data) {
        final width = MediaQuery.sizeOf(context).width;
        final hPad = width >= 600 ? 24.0 : 16.0;
        final textTheme = Theme.of(context).textTheme;

        final counts = orgStatusCounts(data.organizations);
        final orgs = filterAndSortOrgs(
          data.organizations,
          query: searchQuery.value,
          status: statusFilter.value,
          sort: sortKey.value,
        );

        return RefreshIndicator(
          color: scheme.primary,
          backgroundColor: scheme.surfaceContainerLow,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlatformKpiSection(
                        summary: data.summary,
                        currency: currency,
                        compact: compact,
                        t: t,
                      ),
                      const SizedBox(height: 16),
                      SubscriptionHealthStrip(
                        counts: counts,
                        selected: statusFilter.value,
                        onSelected: (f) => statusFilter.value = f,
                        t: t,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              t.organizations.allOrganizations,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            t.organizations.organizationsCount(n: orgs.length),
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OrgListToolbar(
                        query: searchQuery,
                        status: statusFilter,
                        sort: sortKey,
                        counts: counts,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (data.organizations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      _EmptyMessage(text: t.organizations.noOrganizationsYet),
                )
              else if (orgs.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyMessage(
                    text: statusFilter.value == OrgStatusFilter.all
                        ? t.organizations.noMatchingOrganizations
                        : t.organizations.noOrganizationsMatchFilters,
                    actionLabel: t.organizations.clearFilters,
                    onAction: _clearFilters,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                  sliver: SliverList.separated(
                    itemCount: orgs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final org = orgs[index];
                      return OrgStatsCard(
                        key: ValueKey(org.id),
                        org: org,
                        currency: currency,
                        compact: compact,
                        t: t,
                        onTap: () => showOrgSubscriptionDialog(context, org),
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

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 36,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                  minimumSize: const Size(kSuperAdminMinTap, kSuperAdminMinTap),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
