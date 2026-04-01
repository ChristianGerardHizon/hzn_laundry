import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search promos...',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
              ),
            ),
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: promo.isCurrentlyActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.loyalty,
          color: promo.isCurrentlyActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(promo.name),
      subtitle: Row(
        children: [
          Text(
            promo.rewardDisplay,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${dateFormat.format(promo.startDate)} - ${dateFormat.format(promo.endDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: promo.isCurrentlyActive
          ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
          : Icon(Icons.circle, size: 10,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
      onTap: () => PromoDetailRoute(id: promo.id).go(context),
    );
  }
}
