import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/routing/routes/activities.routes.dart';
import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';
import '../controllers/activities_controller.dart';
import '../utils/activity_log_display.dart';

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
      label: 'Management', icon: Icons.business, collectionFilter: 'branches'),
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
      ref.invalidate(activitiesControllerProvider(tab.collectionFilter));
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
          tabs:
              _tabs.map((t) => Tab(icon: Icon(t.icon), text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: _tabs.map((t) => _ActivityTabView(tab: t)).toList(),
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
                              .filterByAction(selected ? action.name : null);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final summary = ActivityLogDisplay.buildShortSummary(log);
    final actor = ActivityLogDisplay.actorLabel(log);
    final when =
        log.created != null ? timeFormat.format(log.created!) : '';

    return ListTile(
      onTap: () => ActivityLogDetailRoute(id: log.id).pushScoped(context),
      leading: CircleAvatar(
        backgroundColor: log.action.color.withValues(alpha: 0.1),
        child: Icon(
          log.action.icon,
          color: log.action.color,
          size: 20,
        ),
      ),
      title: Text(
        summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        when.isEmpty ? 'by $actor' : 'by $actor · $when',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
