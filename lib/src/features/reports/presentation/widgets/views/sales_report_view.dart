import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';

import '../../../../../core/foundation/paginated_state.dart';
import '../../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../pos/domain/payment_method.dart';
import '../../../../pos/domain/payment_type.dart';
import '../../../domain/payment_report_entry.dart';
import '../../../domain/payments_summary.dart';
import '../../controllers/payments_date_range_controller.dart';
import '../../controllers/payments_report_controller.dart';
import '../../controllers/payments_summary_controller.dart';
import '../charts/line_chart_widget.dart';
import '../report_search_bar.dart';

String _shortOrderNumber(String receiptNumber) {
  final parts = receiptNumber.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receiptNumber.length > 4) {
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }
  return receiptNumber;
}

/// View displaying payments received within the selected report period.
///
/// KPIs load from the daily summary view; payment rows load page-by-page.
class SalesReportView extends HookConsumerWidget {
  const SalesReportView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, h:mm a');

  static const _searchFields = [
    ReportSearchField(key: 'customer', label: 'Customer'),
    ReportSearchField(key: 'receipt', label: 'Receipt #'),
    ReportSearchField(key: 'amount', label: 'Amount'),
    ReportSearchField(key: 'reference', label: 'Reference'),
    ReportSearchField(key: 'method', label: 'Method'),
  ];

  static const _defaultSearchKeys = {'customer', 'receipt', 'amount'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(paymentsSummaryProvider);
    final detailAsync = ref.watch(paymentsReportControllerProvider);
    final dateRange = ref.watch(paymentsDateRangeControllerProvider);
    final searchController = useTextEditingController();
    final searchFields = useState(_defaultSearchKeys);

    useEffect(() {
      searchController.clear();
      return null;
    }, [dateRange]);

    final detailState = detailAsync.asData?.value;
    final scrollController = useInfiniteScroll(
      onLoadMore: () =>
          ref.read(paymentsReportControllerProvider.notifier).loadMore(),
      hasMore: detailState?.hasMore ?? false,
      isLoading: detailState?.isLoadingMore ?? false,
    );

    useEffect(() {
      Timer? timer;
      void listener() {
        timer?.cancel();
        timer = Timer(const Duration(milliseconds: 350), () {
          final query = searchController.text.trim();
          final notifier =
              ref.read(paymentsReportControllerProvider.notifier);
          if (query.isEmpty) {
            notifier.clearSearch();
          } else {
            notifier.search(query, fields: searchFields.value.toList());
          }
        });
      }

      searchController.addListener(listener);
      return () {
        timer?.cancel();
        searchController.removeListener(listener);
      };
    }, [searchFields.value]);

    return summaryAsync.when(
      data: (summary) => _buildContent(
        context,
        ref,
        summary,
        detailAsync,
        dateRange,
        searchController: searchController,
        searchFields: searchFields,
        scrollController: scrollController,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(Failure.displayErrorMessage(error)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PaymentsDailySummaryEntry> summary,
    AsyncValue<PaginatedState<PaymentReportEntry>> detailAsync,
    DateTimeRange dateRange, {
    required TextEditingController searchController,
    required ValueNotifier<Set<String>> searchFields,
    required ScrollController scrollController,
  }) {
    final isMobile = Breakpoints.isMobile(context);

    num totalCollected = 0;
    num totalRefunded = 0;
    int paymentCount = 0;
    final methodTotals = <PaymentMethod, num>{};
    final dailyTotals = <DateTime, num>{};

    for (final s in summary) {
      if (s.paymentType == PaymentType.refund) {
        totalRefunded += s.totalAmount;
      } else {
        totalCollected += s.totalAmount;
      }
      paymentCount += s.paymentCount;
      methodTotals[s.paymentMethod] =
          (methodTotals[s.paymentMethod] ?? 0) + s.totalAmount;

      final day = DateTime(s.date.year, s.date.month, s.date.day);
      final amount = s.paymentType == PaymentType.refund
          ? -s.totalAmount
          : s.totalAmount;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
    }

    final netCollected = totalCollected - totalRefunded;
    final detailState = detailAsync.asData?.value;
    final entries = detailState?.items ?? const <PaymentReportEntry>[];
    final detailLoading = detailAsync.isLoading && detailState == null;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(paymentsSummaryProvider);
        ref.invalidate(paymentsReportControllerProvider);
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDateRangeRow(context, ref, dateRange),
                const SizedBox(height: 12),
                _buildKpiSection(
                  context,
                  netCollected: netCollected,
                  totalCollected: totalCollected,
                  totalRefunded: totalRefunded,
                  paymentCount: paymentCount,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                _buildRevenueByDayChart(context, dailyTotals),
                const SizedBox(height: 16),
                if (methodTotals.isNotEmpty) ...[
                  _buildMethodBreakdown(context, methodTotals),
                  const SizedBox(height: 16),
                ],
                ReportSearchBar(
                  fields: _searchFields,
                  selectedKeys: searchFields.value,
                  controller: searchController,
                  onSelectedKeysChanged: (keys) {
                    searchFields.value = keys;
                    final query = searchController.text.trim();
                    if (query.isNotEmpty) {
                      ref
                          .read(paymentsReportControllerProvider.notifier)
                          .search(query, fields: keys.toList());
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (!detailLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      detailState != null
                          ? '${detailState.totalItems} payments'
                          : '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ]),
            ),
          ),
          if (detailLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (detailAsync.hasError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    Failure.displayErrorMessage(detailAsync.error),
                  ),
                ),
              ),
            )
          else if (entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                child: _buildEmptyState(context),
              ),
            )
          else if (isMobile)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= entries.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return _buildMobilePaymentCard(context, entries[index]);
                  },
                  childCount: entries.length +
                      (detailState?.isLoadingMore == true ? 1 : 0),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: _buildDesktopPaymentsTable(context, entries),
              ),
            ),
          if (detailState != null && entries.isNotEmpty)
            SliverToBoxAdapter(
              child: EndOfListIndicator(
                isLoadingMore: detailState.isLoadingMore,
                hasReachedEnd: detailState.hasReachedEnd,
              ),
            ),
        ],
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
      final adjustedEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
        999,
      );
      ref
          .read(paymentsDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  Widget _buildRevenueByDayChart(
    BuildContext context,
    Map<DateTime, num> dailyTotals,
  ) {
    if (dailyTotals.isEmpty) return const SizedBox.shrink();

    final sortedDays = dailyTotals.keys.toList()..sort();
    final spots = sortedDays.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        dailyTotals[entry.value]!.toDouble(),
      );
    }).toList();
    final xLabels =
        sortedDays.map((d) => DateFormat('MMM d').format(d)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'Payments Received per Day',
          spots: spots,
          xLabels: xLabels,
          lineColor: Colors.green,
          yAxisFormatter: (value) =>
              _currencyFormat.format(value).replaceAll('.00', ''),
          height: 220,
        ),
      ),
    );
  }

  Widget _buildKpiSection(
    BuildContext context, {
    required num netCollected,
    required num totalCollected,
    required num totalRefunded,
    required int paymentCount,
    required bool isMobile,
  }) {
    final cards = [
      _KpiData('Net Collected', _currencyFormat.format(netCollected),
          Icons.account_balance_wallet, Colors.green),
      _KpiData('Total Received', _currencyFormat.format(totalCollected),
          Icons.arrow_downward, Colors.blue),
      _KpiData('Refunded', _currencyFormat.format(totalRefunded),
          Icons.arrow_upward, Colors.red),
      _KpiData(
          'Payments', '$paymentCount', Icons.receipt_long, Colors.orange),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[0].title,
                    value: cards[0].value,
                    icon: cards[0].icon,
                    color: cards[0].color)),
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[1].title,
                    value: cards[1].value,
                    icon: cards[1].icon,
                    color: cards[1].color)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[2].title,
                    value: cards[2].value,
                    icon: cards[2].icon,
                    color: cards[2].color)),
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[3].title,
                    value: cards[3].value,
                    icon: cards[3].icon,
                    color: cards[3].color)),
          ]),
        ],
      );
    }

    return Row(
      children: cards
          .expand((c) => [
                Expanded(
                    child: KpiCard(
                        compact: true,
                        title: c.title,
                        value: c.value,
                        icon: c.icon,
                        color: c.color)),
                const SizedBox(width: 12),
              ])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildMethodBreakdown(
    BuildContext context,
    Map<PaymentMethod, num> methodTotals,
  ) {
    final theme = Theme.of(context);
    final sorted = methodTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Payment Method',
                style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: sorted.map((entry) {
                final (IconData icon, Color color) =
                    _methodStyle(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(entry.key.displayName,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(width: 4),
                    Text(_currencyFormat.format(entry.value),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _methodStyle(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => (Icons.payments, Colors.green),
      PaymentMethod.gcash => (Icons.phone_android, Colors.blue),
      PaymentMethod.card => (Icons.credit_card, Colors.blue),
      PaymentMethod.bankTransfer => (Icons.account_balance, Colors.purple),
      PaymentMethod.check => (Icons.description, Colors.brown),
    };
  }

  Widget _buildDesktopPaymentsTable(
    BuildContext context,
    List<PaymentReportEntry> entries,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 44,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Receipt #')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('')),
                ],
                rows: entries.map((e) => _buildDataRow(context, e)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, PaymentReportEntry entry) {
    final p = entry.payment;
    final isRefund = p.type == PaymentType.refund;
    final theme = Theme.of(context);

    return DataRow(
      cells: [
        DataCell(Text(
          p.postedDate != null ? _dateTimeFormat.format(p.postedDate!) : '—',
        )),
        DataCell(Text(_shortOrderNumber(entry.receiptNumber))),
        DataCell(Text(entry.customerName ?? '—')),
        DataCell(Text(
          '${isRefund ? '-' : ''}${_currencyFormat.format(p.amount)}',
          style: TextStyle(
            color: isRefund ? Colors.red : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        )),
        DataCell(Text(p.paymentMethod.displayName)),
        DataCell(_buildTypeChip(context, p.type)),
        DataCell(Text(p.paymentRef ?? '—',
            style: theme.textTheme.bodySmall)),
        DataCell(
          IconButton(
            icon: Icon(Icons.open_in_new,
                size: 16, color: theme.colorScheme.primary),
            tooltip: 'View order',
            onPressed: () =>
                SaleDetailRoute(id: entry.saleId).goScoped(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePaymentCard(
    BuildContext context,
    PaymentReportEntry entry,
  ) {
    final theme = Theme.of(context);
    final p = entry.payment;
    final isRefund = p.type == PaymentType.refund;
    final (IconData methodIcon, Color methodColor) =
        _methodStyle(p.paymentMethod);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SaleDetailRoute(id: entry.saleId).goScoped(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${isRefund ? '-' : ''}${_currencyFormat.format(p.amount)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isRefund ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  _buildTypeChip(context, p.type),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (entry.receiptNumber.isNotEmpty) ...[
                    Text(_shortOrderNumber(entry.receiptNumber),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500)),
                    if (entry.customerName != null &&
                        entry.customerName!.isNotEmpty) ...[
                      Text(' · ',
                          style: TextStyle(
                              color: theme.colorScheme.outline)),
                      Expanded(
                        child: Text(
                          entry.customerName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(methodIcon, size: 14, color: methodColor),
                  const SizedBox(width: 4),
                  Text(p.paymentMethod.displayName,
                      style: theme.textTheme.labelSmall),
                  if (p.paymentRef != null &&
                      p.paymentRef!.isNotEmpty) ...[
                    Text(' · ',
                        style:
                            TextStyle(color: theme.colorScheme.outline)),
                    Flexible(
                      child: Text(p.paymentRef!,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    p.postedDate != null
                        ? _dateTimeFormat.format(p.postedDate!)
                        : '—',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_outlined,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No payments found for this period.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, PaymentType type) {
    final (Color color, String label) = switch (type) {
      PaymentType.payment => (Colors.green, 'Payment'),
      PaymentType.deposit => (Colors.blue, 'GCash/Bank'),
      PaymentType.refund => (Colors.red, 'Refund'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _KpiData {
  const _KpiData(this.title, this.value, this.icon, this.color);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
