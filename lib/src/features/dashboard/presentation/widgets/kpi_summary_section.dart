import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../controllers/today_incentive_controller.dart';
import 'kpi_card.dart';
import 'today_incentive_modal.dart';

/// Section displaying KPI summary cards on the dashboard.
///
/// Responsive layout:
/// - Desktop (≥1200px): 4-column grid
/// - Tablet (600–1199px): 2-column grid
/// - Mobile (<600px): 1-column (full width)
class KpiSummarySection extends ConsumerWidget {
  const KpiSummarySection({super.key});

  static final _currency =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incentiveAsync = ref.watch(todayIncentiveSummaryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          const spacing = 12.0;

          final int columns;
          if (screenWidth >= Breakpoints.desktop) {
            columns = 4;
          } else if (screenWidth >= Breakpoints.mobile) {
            columns = 2;
          } else {
            columns = 1;
          }

          final rawWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          // Guard against negative/zero widths on extremely narrow
          // constraints, which would throw a BoxConstraints assertion.
          final cardWidth = rawWidth.isFinite && rawWidth > 0 ? rawWidth : 0.0;

          Widget incentiveCard = incentiveAsync.when(
            data: (summary) => KpiCard(
              title: "Today's Incentive",
              value: _currency.format(summary.totalIncentive),
              icon: Icons.payments,
              subtitle:
                  '${summary.orders.length} qualifying order${summary.orders.length == 1 ? '' : 's'}',
              compact: true,
              color: Colors.purple,
              onTap: () => showTodayIncentiveModal(context, summary),
            ),
            loading: () => _buildLoadingCard(),
            error: (_, __) => _buildErrorCard(context),
          );

          return SizedBox(
            width: cardWidth,
            child: incentiveCard,
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: SizedBox(
        height: 76,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.payments,
                      color: theme.colorScheme.error, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '--',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Today's Incentive",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
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
