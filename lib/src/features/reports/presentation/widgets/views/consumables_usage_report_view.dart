import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/nav_permissions.dart';
import '../../../../dashboard/domain/consumables_usage_summary.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../users/domain/user_role.dart';
import '../../controllers/consumables_usage_date_range_controller.dart';
import '../../controllers/consumables_usage_report_controller.dart';

/// Period breakdown of house consumable usage.
class ConsumablesUsageReportView extends ConsumerWidget {
  const ConsumablesUsageReportView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _qty = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(consumablesUsageReportProvider);
    final dateRange = ref.watch(consumablesUsageDateRangeControllerProvider);
    final role = ref.watch(currentUserRoleProvider).value;
    final showCost = role != null &&
        (role.isAdmin || role.hasPermission(Permissions.usageCostView));

    return summaryAsync.when(
      data: (summary) => _buildContent(
        context,
        ref,
        summary,
        dateRange,
        showCost: showCost,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading consumables: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ConsumablesUsageSummaryData summary,
    DateTimeRange dateRange, {
    required bool showCost,
  }) {
    final isMobile = Breakpoints.isMobile(context);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(consumablesUsageReportProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeRow(context, ref, dateRange),
            const SizedBox(height: 12),
            _buildKpiSection(
              context,
              summary: summary,
              showCost: showCost,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            Text(
              'By product',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (summary.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No consumables recorded in this period.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < summary.items.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        title: Text(summary.items[i].productName),
                        subtitle: Text(
                          'in ${summary.items[i].orderCount} order'
                          '${summary.items[i].orderCount == 1 ? '' : 's'}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '×${_qty.format(summary.items[i].quantity)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (showCost)
                              Text(
                                _currencyFormat.format(summary.items[i].cost),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeRow(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) {
    final theme = Theme.of(context);
    final startStr = _dateFormat.format(dateRange.start);
    final endStr = _dateFormat.format(dateRange.end);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickDateRange(context, ref, dateRange),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$startStr – $endStr',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      ref
          .read(consumablesUsageDateRangeControllerProvider.notifier)
          .setRange(picked);
    }
  }

  Widget _buildKpiSection(
    BuildContext context, {
    required ConsumablesUsageSummaryData summary,
    required bool showCost,
    required bool isMobile,
  }) {
    final cards = [
      KpiCard(
        compact: true,
        title: 'Total used',
        value: _qty.format(summary.totalQuantity),
        icon: Icons.science_outlined,
        color: Colors.deepPurple,
      ),
      KpiCard(
        compact: true,
        title: 'Avg per order',
        value: _qty.format(summary.averagePerOrder),
        icon: Icons.analytics_outlined,
        color: Colors.indigo,
        subtitle: '${summary.orderCount} orders',
      ),
      if (showCost)
        KpiCard(
          compact: true,
          title: 'Material cost',
          value: _currencyFormat.format(summary.totalCost),
          icon: Icons.payments_outlined,
          color: Colors.teal,
        ),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final card in cards)
            SizedBox(
              width: (MediaQuery.sizeOf(context).width - 32) / 2,
              child: card,
            ),
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}
