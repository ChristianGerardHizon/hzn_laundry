import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/list/list.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/routing/routes/promos.routes.dart';
import '../../domain/promo.dart';
import '../controllers/promos_controller.dart';
import 'promo_form_dialog.dart';

/// List panel for displaying promos with search and create.
class PromoListPanel extends HookConsumerWidget {
  const PromoListPanel({
    super.key,
    required this.promos,
  });

  final List<Promo> promos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final filteredPromos = searchQuery.value.isEmpty
        ? promos
        : promos
            .where((p) => p.name
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Promos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(promosControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          ListToolbar(
            controller: searchController,
            hintText: 'Search promos...',
            // Filtering is live via the controller listener; nothing to submit.
            onSearch: () {},
            onTextChanged: (_) {},
          ),
          Expanded(
            child: filteredPromos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.loyalty,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No promos yet'
                              : 'No promos match "${searchQuery.value}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(promosControllerProvider.notifier).refresh(),
                    child: ListView.builder(
                      itemCount: filteredPromos.length,
                      itemBuilder: (context, index) {
                        final promo = filteredPromos[index];
                        return _PromoListTile(promo: promo);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final result = await showPromoFormDialog(context);
    if (result == true) {
      ref.read(promosControllerProvider.notifier).refresh();
    }
  }
}

class _PromoListTile extends StatelessWidget {
  const _PromoListTile({required this.promo});

  final Promo promo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');
    final active = promo.isCurrentlyActive;

    return AppListRow(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor:
            active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        child: Icon(
          Icons.loyalty,
          color:
              active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
      title: Text(promo.name),
      subtitle: Text(
        '${promo.rewardDisplay} · ${dateFormat.format(promo.startDate)} - ${dateFormat.format(promo.endDate)}',
      ),
      trailing: active
          ? const RowChip(label: 'Active', color: Colors.green)
          : null,
      onTap: () => PromoDetailRoute(id: promo.id).goScoped(context),
    );
  }
}