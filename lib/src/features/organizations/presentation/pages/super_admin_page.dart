import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/auth.routes.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/organization_platform_stats.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organization_platform_stats_controller.dart';
import '../controllers/organization_selection_gate.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);
const _kMuted = Color(0xFF9CA3AF);

/// Platform dashboard for `system.admin` users.
class SuperAdminPage extends HookConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCreating = useState(false);
    final searchQuery = useState('');
    ref.watch(currentOrganizationControllerProvider);
    final statsAsync = ref.watch(organizationPlatformStatsControllerProvider);

    final currency = useMemoized(
      () => NumberFormat.currency(symbol: '₱', decimalDigits: 2),
    );
    final compact = useMemoized(() => NumberFormat.compact());

    Future<void> openCreate() async {
      if (isCreating.value) return;
      isCreating.value = true;
      try {
        final created = await showCreateOrganizationSetupDialog(context);
        if (created == true && context.mounted) {
          ref.read(organizationSelectionConfirmedProvider.notifier).confirm();
          showSuccessSnackBar(
            context,
            message: t.organizations.onboardingComplete,
            useRootMessenger: false,
          );
          ref
              .read(organizationPlatformStatsControllerProvider.notifier)
              .refresh();
          const SplashRoute().go(context);
        }
      } finally {
        if (context.mounted) isCreating.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _kInk,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: isCreating.value
                                  ? null
                                  : () => const SelectOrganizationRoute()
                                      .go(context),
                              style: TextButton.styleFrom(
                                foregroundColor: _kBrandTeal,
                                minimumSize: const Size(44, 44),
                              ),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(t.organizations.back),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: isCreating.value ? null : openCreate,
                              style: FilledButton.styleFrom(
                                backgroundColor: _kBrandTeal,
                                foregroundColor: _kInk,
                                minimumSize: const Size(44, 44),
                              ),
                              icon: isCreating.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _kInk,
                                      ),
                                    )
                                  : const Icon(Icons.add_business_outlined),
                              label: Text(t.organizations.create),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Column(
                          children: [
                            Assets.icons.appIconTransparent.image(
                              width: 48,
                              height: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.organizations.superAdminTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.organizations.superAdminSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.62),
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: statsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: _kBrandTeal,
                            ),
                          ),
                          error: (e, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: ErrorState.fromError(
                                e,
                                onRetry: () => ref
                                    .read(
                                      organizationPlatformStatsControllerProvider
                                          .notifier,
                                    )
                                    .refresh(),
                              ),
                            ),
                          ),
                          data: (data) {
                            final query = searchQuery.value.trim().toLowerCase();
                            final orgs = query.isEmpty
                                ? data.organizations
                                : data.organizations
                                    .where(
                                      (o) =>
                                          o.name.toLowerCase().contains(query),
                                    )
                                    .toList();

                            return RefreshIndicator(
                              color: _kBrandTeal,
                              onRefresh: () => ref
                                  .read(
                                    organizationPlatformStatsControllerProvider
                                        .notifier,
                                  )
                                  .refresh(),
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            t.organizations.platformOverview,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            onChanged: (v) =>
                                                searchQuery.value = v,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: t.organizations
                                                  .searchOrganizations,
                                              hintStyle: TextStyle(
                                                color: _kMuted.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: _kMuted.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: _kSurface,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: _kSurfaceBorder,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: _kSurfaceBorder,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: _kBrandTeal,
                                                ),
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
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.62),
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
                                            t.organizations
                                                .noMatchingOrganizations,
                                            style: TextStyle(
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.62),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(
                                        24,
                                        0,
                                        24,
                                        24,
                                      ),
                                      sliver: SliverList.separated(
                                        itemCount: orgs.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          return _OrgStatsCard(
                                            key: ValueKey(orgs[index].id),
                                            org: orgs[index],
                                            currency: currency,
                                            compact: compact,
                                            t: t,
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
        color: _kSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSurfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 18, color: _kBrandTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _kMuted,
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
  });

  final OrganizationPlatformStats org;
  final NumberFormat currency;
  final NumberFormat compact;
  final Translations t;

  @override
  Widget build(BuildContext context) {
    final letter = org.name.isNotEmpty ? org.name[0].toUpperCase() : '?';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSurfaceBorder),
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
                    color: _kBrandTeal.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: _kBrandTeal,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (org.slug.isNotEmpty)
                        Text(
                          org.slug,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _kMuted,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: org.isOnboarded
                        ? _kBrandTeal.withValues(alpha: 0.16)
                        : Colors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    org.isOnboarded
                        ? t.organizations.onboarded
                        : t.organizations.notOnboarded,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: org.isOnboarded ? _kBrandTeal : Colors.orangeAccent,
                    ),
                  ),
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
        color: _kInk.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _kMuted,
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
