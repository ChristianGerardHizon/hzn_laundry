import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../domain/add_ons_summary.dart';
import '../../domain/loads_summary.dart';
import '../../domain/sales_summary.dart';
import '../controllers/dashboard_refresh.dart';
import '../controllers/sales_summary_controller.dart';
import '../controllers/sales_summary_hidden_date_provider.dart';
import '../controllers/total_packs_summary_controller.dart';
import 'add_ons_breakdown_modal.dart';
import 'dashboard_section_print_button.dart';
import 'kpi_card.dart';
import 'loads_breakdown_modal.dart';
import 'total_packs_modal.dart';

/// Dashboard section showing today's sales totals.
///
/// Each KPI card (Total Sales, Total Paid, Total Unpaid) is tappable
/// and opens a modal with the filtered breakdown list.
/// The section can be collapsed/expanded by tapping the header.
class SalesSummarySection extends HookConsumerWidget {
  const SalesSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final hiddenDateAsync = ref.watch(salesSummaryHiddenDateProvider);
    final theme = Theme.of(context);
    final isRefreshing = useState(false);
    final refreshOverlay = useRef<OverlayEntry?>(null);
    final isExpanded = !hiddenDateAsync.maybeWhen(
      data: (storedDate) => isSalesSummaryHiddenFor(
        storedDate: storedDate,
        now: DateTime.now(),
      ),
      orElse: () => false,
    );

    useEffect(() {
      return () {
        refreshOverlay.value?.remove();
        refreshOverlay.value = null;
      };
    }, const []);

    void showRefreshCompleteOverlay() {
      refreshOverlay.value?.remove();
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _RefreshCompleteToast(
          onFinished: () {
            entry.remove();
            if (refreshOverlay.value == entry) {
              refreshOverlay.value = null;
            }
          },
        ),
      );
      refreshOverlay.value = entry;
      Overlay.of(context).insert(entry);
    }

    Future<void> handleRefresh() async {
      if (isRefreshing.value) return;
      isRefreshing.value = true;
      try {
        await Future.wait([
          refreshAllDashboardData(ref),
          Future<void>.delayed(const Duration(seconds: 1)),
        ]);
        if (!context.mounted) return;
        showRefreshCompleteOverlay();
      } finally {
        if (context.mounted) {
          isRefreshing.value = false;
        }
      }
    }

    Future<void> toggleExpanded() async {
      final notifier = ref.read(salesSummaryHiddenDateProvider.notifier);
      if (isExpanded) {
        await notifier.hideForToday();
      } else {
        await notifier.show();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (tappable to toggle)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: toggleExpanded,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today's Summary",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          isExpanded ? 'Press to hide' : 'Press to show',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.0 : -0.25,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 20,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: isRefreshing.value ? null : handleRefresh,
                icon: isRefreshing.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: summaryAsync.when(
                data: (data) => _SalesSummaryContent(data: data),
                loading: () => const _LoadingCards(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _RefreshCompleteToast extends StatefulWidget {
  const _RefreshCompleteToast({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_RefreshCompleteToast> createState() => _RefreshCompleteToastState();
}

class _RefreshCompleteToastState extends State<_RefreshCompleteToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _play();
  }

  Future<void> _play() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FadeTransition(
                opacity: _opacity,
                child: ScaleTransition(
                  scale: _scale,
                  child: Material(
                    elevation: 6,
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done,
                            color: theme.colorScheme.onInverseSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pulled new data complete',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SalesSummaryContent extends ConsumerWidget {
  const _SalesSummaryContent({required this.data});

  final SalesSummaryData data;

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  String _fmt(num amount) => _currency.format(amount);

  static final _qty = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(totalPacksSummaryProvider);
    final addOns = AddOnsSummaryData.fromSalesItems(data.salesItems);
    final loads = LoadsSummaryData.fromSalesItems(data.salesItems);

    final salesCards = [
      KpiCard(
        title: 'Total Sales',
        value: _fmt(data.totalSales),
        icon: Icons.point_of_sale,
        subtitle: '${data.salesItems.length} orders today',
        compact: true,
        color: Colors.blue,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Total Sales',
          icon: Icons.point_of_sale,
          color: Colors.blue,
          items: data.salesItems,
          total: data.totalSales,
        ),
      ),
      KpiCard(
        title: 'Payments Received',
        value: _fmt(data.totalPaymentsReceived),
        icon: Icons.payments_outlined,
        subtitle: '${data.paymentItems.length} payment entries',
        compact: true,
        color: Colors.green,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Payments Received',
          icon: Icons.payments_outlined,
          color: Colors.green,
          items: data.paymentItems,
          total: data.totalPaymentsReceived,
        ),
      ),
      KpiCard(
        title: 'Outstanding',
        value: _fmt(data.totalOutstanding),
        icon: Icons.pending_outlined,
        subtitle: '${data.outstandingItems.length} orders pending',
        compact: true,
        color: Colors.orange,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Outstanding',
          icon: Icons.pending_outlined,
          color: Colors.orange,
          items: data.outstandingItems,
          total: data.totalOutstanding,
        ),
      ),
      KpiCard(
        title: 'Add-ons Sold',
        value: _qty.format(addOns.totalQuantity),
        icon: Icons.shopping_bag_outlined,
        subtitle: addOns.items.isEmpty
            ? 'No add-ons today'
            : '${addOns.items.length} product${addOns.items.length == 1 ? '' : 's'} · ${_fmt(addOns.totalRevenue)}',
        compact: true,
        color: Colors.teal,
        onTap: () => showAddOnsBreakdownModal(
          context,
          addOns,
          color: Colors.teal,
        ),
      ),
      KpiCard(
        title: 'Loads',
        value: '${loads.totalLoads}',
        icon: Icons.local_laundry_service,
        subtitle: loads.orders.isEmpty
            ? 'No loads today'
            : '${loads.orders.length} order${loads.orders.length == 1 ? '' : 's'}',
        compact: true,
        color: Colors.indigo,
        onTap: () => showLoadsBreakdownModal(
          context,
          loads,
          color: Colors.indigo,
        ),
      ),
      packsAsync.when(
        data: (summary) => KpiCard(
          title: 'Total Packs',
          value: '${summary.totalPacks}',
          icon: Icons.inventory_2_outlined,
          subtitle: summary.orders.isEmpty
              ? 'No packs today'
              : '${summary.orders.length} order${summary.orders.length == 1 ? '' : 's'}',
          compact: true,
          color: Colors.cyan,
          onTap: () => showTotalPacksModal(context, summary),
        ),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _LoadingCard(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _kpiGridLayout(
          maxWidth: constraints.maxWidth,
          itemCount: salesCards.length,
        );

        return Wrap(
          spacing: _kpiSpacing,
          runSpacing: _kpiSpacing,
          children: salesCards
              .map((c) => SizedBox(width: layout.cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  void _showBreakdownModal(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<SalesSummaryItem> items,
    required num total,
  }) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      builder: (_) => _BreakdownDialog(
        title: title,
        icon: icon,
        color: color,
        items: items,
        total: total,
      ),
    );
  }
}

/// Full-screen dialog showing the breakdown list of sales.
class _BreakdownDialog extends StatelessWidget {
  const _BreakdownDialog({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.total,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<SalesSummaryItem> items;
  final num total;

  String _formatCurrency(num amount) {
    return NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatCurrency(total)} · ${items.length} orders',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DashboardSectionPrintButton.sales(
                    sectionTitle: title,
                    salesItems: items,
                    total: total,
                    color: color,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No orders'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => _SalesBreakdownTile(
                    item: items[index],
                    itemNumber: index + 1,
                    accentColor: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SalesBreakdownTile extends StatelessWidget {
  const _SalesBreakdownTile({
    required this.item,
    required this.itemNumber,
    required this.accentColor,
  });

  final SalesSummaryItem item;
  final int itemNumber;
  final Color accentColor;

  String _shortOrderNumber(String receiptNumber) {
    final parts = receiptNumber.split('-');
    if (parts.length >= 3) return '#${parts.last}';
    if (receiptNumber.length > 4) {
      return '#${receiptNumber.substring(receiptNumber.length - 4)}';
    }
    return receiptNumber;
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);

    if (date == today) {
      return DateFormat('h:mm a').format(local);
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return InkWell(
      onTap: () => showSaleDetailDialog(context, saleId: item.saleId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _ItemNumberBadge(number: itemNumber, accentColor: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: customer name, badges, amount
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName != null &&
                                      item.customerName!.isNotEmpty
                                  ? item.customerName!
                                  : _shortOrderNumber(item.receiptNumber),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _shortOrderNumber(item.receiptNumber),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.isBacklog) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Backlog',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (item.customerName == null ||
                                item.customerName!.isEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Walk-in customer',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(item.totalAmount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.postedDate != null) ...[
                                Text(
                                  _formatTime(item.postedDate!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              _PaymentChip(label: item.statusLabel),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Services
                  if (item.serviceItems.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_laundry_service,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.serviceItems.map((e) {
                              final qty =
                                  e.service?.formatQuantity(e.quantity) ??
                                      '${e.quantity}';
                              return '${e.serviceName} x$qty';
                            }).join(', '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Add-ons
                  if (item.saleItems.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.saleItems
                                .map((e) => '${e.productName} x${e.quantity}')
                                .join(', '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}

class _ItemNumberBadge extends StatelessWidget {
  const _ItemNumberBadge({required this.number, required this.accentColor});

  final int number;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Paid' => Colors.green,
      'Full Payment' => Colors.green,
      'Partial' => Colors.amber.shade800,
      'Partial Payment' => Colors.amber.shade800,
      _ => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

const _kpiSpacing = 8.0;
const _kpiMinCardWidth = 168.0;
const _kpiMaxCardWidth = 220.0;

({int cols, double cardWidth}) _kpiGridLayout({
  required double maxWidth,
  required int itemCount,
}) {
  if (itemCount <= 0 || !maxWidth.isFinite || maxWidth <= 0) {
    return (cols: 1, cardWidth: 0);
  }

  final int cols;
  final isMobileWidth = maxWidth < Breakpoints.mobile;
  if (isMobileWidth) {
    cols = itemCount >= 2 ? 2 : 1;
  } else {
    cols = ((maxWidth + _kpiSpacing) / (_kpiMinCardWidth + _kpiSpacing))
        .floor()
        .clamp(1, itemCount);
  }

  final stretched = (maxWidth - _kpiSpacing * (cols - 1)) / cols;
  final cardWidth =
      isMobileWidth ? stretched : stretched.clamp(0.0, _kpiMaxCardWidth);
  return (cols: cols, cardWidth: cardWidth);
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    const cardCount = 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _kpiGridLayout(
          maxWidth: constraints.maxWidth,
          itemCount: cardCount,
        );

        return Wrap(
          spacing: _kpiSpacing,
          runSpacing: _kpiSpacing,
          children: List.generate(
            cardCount,
            (_) =>
                SizedBox(width: layout.cardWidth, child: const _LoadingCard()),
          ),
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
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
}
