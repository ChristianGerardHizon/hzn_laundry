import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/customers.routes.dart';
import '../../../../core/routing/routes/employees.routes.dart';
import '../../../../core/routing/routes/products.routes.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/routing/routes/services.routes.dart';
import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';
import '../controllers/activities_controller.dart';

/// Tab definition for an activity feature filter.
class _ActivityTab {
  const _ActivityTab({
    required this.label,
    required this.icon,
    required this.collectionFilter,
  });

  final String label;
  final IconData icon;

  /// Empty string means "all collections".
  final String collectionFilter;
}

const _tabs = <_ActivityTab>[
  _ActivityTab(label: 'All', icon: Icons.list, collectionFilter: ''),
  _ActivityTab(
      label: 'Sales', icon: Icons.receipt_long, collectionFilter: 'sales'),
  _ActivityTab(
      label: 'Products', icon: Icons.inventory_2, collectionFilter: 'products'),
  _ActivityTab(
      label: 'Services',
      icon: Icons.miscellaneous_services,
      collectionFilter: 'services'),
  _ActivityTab(
      label: 'Customers', icon: Icons.people, collectionFilter: 'customers'),
  _ActivityTab(
      label: 'Employees', icon: Icons.badge, collectionFilter: 'employees'),
  _ActivityTab(
      label: 'Payments', icon: Icons.payment, collectionFilter: 'payments'),
  _ActivityTab(
      label: 'Organization',
      icon: Icons.business,
      collectionFilter: 'branches'),
  _ActivityTab(
      label: 'Promos', icon: Icons.loyalty, collectionFilter: 'promos'),
];

/// Page displaying a tabbed, filterable, paginated list of activity logs.
class ActivitiesPage extends HookConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: _tabs.length);

    void refreshCurrentTab() {
      final tab = _tabs[tabController.index];
      ref.invalidate(
          activitiesControllerProvider(tab.collectionFilter));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshCurrentTab,
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((t) => Tab(icon: Icon(t.icon), text: t.label))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children:
            _tabs.map((t) => _ActivityTabView(tab: t)).toList(),
      ),
    );
  }
}

/// A single tab view showing activities for a specific collection filter.
class _ActivityTabView extends HookConsumerWidget {
  const _ActivityTabView({required this.tab});

  final _ActivityTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controllerAsync =
        ref.watch(activitiesControllerProvider(tab.collectionFilter));
    final scrollController = useScrollController();
    final selectedAction = useState<ActivityAction?>(null);

    // Infinite scroll listener
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref
              .read(activitiesControllerProvider(tab.collectionFilter).notifier)
              .loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Column(
      children: [
        // Action filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ActivityAction.values
                .map((action) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(action.icon, size: 14, color: action.color),
                            const SizedBox(width: 4),
                            Text(action.displayName),
                          ],
                        ),
                        selected: selectedAction.value == action,
                        onSelected: (selected) {
                          selectedAction.value = selected ? action : null;
                          ref
                              .read(activitiesControllerProvider(
                                      tab.collectionFilter)
                                  .notifier)
                              .filterByAction(
                                  selected ? action.name : null);
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
        const Divider(height: 1),

        // Activity list
        Expanded(
          child: controllerAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text('Failed to load activities'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(
                        activitiesControllerProvider(tab.collectionFilter)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (activitiesState) {
              if (activitiesState.logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activities found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Activities will appear here as changes are made',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref
                    .read(activitiesControllerProvider(tab.collectionFilter)
                        .notifier)
                    .refresh(),
                child: ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: activitiesState.logs.length +
                      (activitiesState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= activitiesState.logs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final log = activitiesState.logs[index];
                    return _ActivityTile(log: log);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.log});

  final ActivityLog log;

  /// Navigate to the detail page for the record, if a route exists.
  void _openRecord(BuildContext context) {
    // Don't navigate for deleted records — they no longer exist.
    if (log.action == ActivityAction.delete) return;

    final id = log.recordId;
    switch (log.collection) {
      case 'sales':
        SaleDetailRoute(id: id).go(context);
      case 'products':
        ProductDetailRoute(id: id).go(context);
      case 'services':
        ServiceDetailRoute(id: id).go(context);
      case 'customers':
        CustomerDetailRoute(id: id).go(context);
      case 'employees':
        EmployeeDetailRoute(id: id).go(context);
      default:
        // No detail page for this collection
        break;
    }
  }

  /// Whether this log entry has a navigable detail page.
  bool get _hasDetailPage {
    if (log.action == ActivityAction.delete) return false;
    return const [
      'sales',
      'products',
      'services',
      'customers',
      'employees',
    ].contains(log.collection);
  }

  /// Format the changes map into human-readable lines.
  static const _fieldLabels = {
    'orderStatus': 'Order status',
    'status': 'Sale status',
    'totalAmount': 'Total',
    'isPaid': 'Paid',
    'unitPrice': 'Unit price',
    'subtotal': 'Subtotal',
    'price': 'Price',
    'quantity': 'Quantity',
    'name': 'Name',
    'customerName': 'Customer',
    'machineName': 'Machine',
    'storageName': 'Storage',
    'notes': 'Notes',
    'rate': 'Rate',
    'description': 'Description',
    'phone': 'Phone',
    'email': 'Email',
    'address': 'Address',
  };

  static const _orderStatusLabels = {
    'pending': 'Pending',
    'processing': 'Processing',
    'ready': 'Ready',
    'pickedUp': 'Picked Up',
  };

  static const _saleStatusLabels = {
    'pending': 'Pending',
    'completed': 'Completed',
    'refunded': 'Refunded',
    'voided': 'Voided',
  };

  String _formatFieldValue(String field, dynamic value) {
    if (value == null || value == '') return '(empty)';
    if (field == 'orderStatus') {
      return _orderStatusLabels[value] ?? '$value';
    }
    if (field == 'status') {
      return _saleStatusLabels[value] ?? '$value';
    }
    if (field == 'isPaid') return value == true ? 'Paid' : 'Unpaid';
    if (field == 'totalAmount' ||
        field == 'unitPrice' ||
        field == 'subtotal' ||
        field == 'price' ||
        field == 'rate') {
      final n = num.tryParse('$value');
      if (n != null) return '₱${n.toStringAsFixed(2)}';
    }
    return '$value';
  }

  /// Fields to hide from the change summary (internal/redundant).
  static const _hiddenFields = {
    'pickedUpAt',
    'postedDate',
    'collectionId',
    'collectionName',
  };

  String? _buildChangeSummary() {
    final changes = log.changes;
    if (changes == null || changes.isEmpty) return null;

    final lines = <String>[];
    for (final entry in changes.entries) {
      final field = entry.key;
      if (_hiddenFields.contains(field)) continue;
      final change = entry.value;
      if (change is! Map) continue;

      final label = _fieldLabels[field] ?? _camelToLabel(field);
      final oldVal = _formatFieldValue(field, change['old']);
      final newVal = _formatFieldValue(field, change['new']);
      lines.add('$label: $oldVal → $newVal');
    }
    return lines.isEmpty ? null : lines.join('\n');
  }

  String _camelToLabel(String s) {
    final spaced = s.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(1)!.toLowerCase()}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final changeSummary = _buildChangeSummary();

    return ListTile(
      onTap: _hasDetailPage ? () => _openRecord(context) : null,
      isThreeLine: changeSummary != null,
      leading: CircleAvatar(
        backgroundColor: log.action.color.withValues(alpha: 0.1),
        child: Icon(
          log.action.icon,
          color: log.action.color,
          size: 20,
        ),
      ),
      title: Text(
        log.description ?? '${log.action.displayName} ${log.collection}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (changeSummary != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text(
                changeSummary,
                style: theme.textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.collectionDisplayName,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (log.userName != null && log.userName!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.userName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.created != null
                      ? timeFormat.format(log.created!)
                      : '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: _hasDetailPage
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }
}
