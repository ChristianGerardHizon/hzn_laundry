import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/services.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/service.dart';
import '../controllers/services_controller.dart';
import 'service_form_sheet.dart';

/// List panel for displaying services with search and create.
class ServiceListPanel extends HookConsumerWidget {
  const ServiceListPanel({
    super.key,
    required this.services,
  });

  final List<Service> services;

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

    final filteredServices = searchQuery.value.isEmpty
        ? services
        : services
            .where((s) => s.name
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(servicesControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search services...',
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

          // Services list
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.miscellaneous_services,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No services yet'
                              : 'No services match "${searchQuery.value}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(servicesControllerProvider.notifier).refresh(),
                    child: ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return _ServiceListTile(service: service);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final result = await showServiceFormSheet(context);
    if (result == true) {
      ref.read(servicesControllerProvider.notifier).refresh();
    }
  }
}

class _ServiceListTile extends StatelessWidget {
  const _ServiceListTile({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.miscellaneous_services,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(service.name),
      subtitle: Row(
        children: [
          Text(
            service.hasVariablePrice
                ? 'Variable'
                : service.price.toCurrency(),
            style: TextStyle(
              color: service.hasVariablePrice
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (service.categoryName != null) ...[
            const SizedBox(width: 8),
            Text(
              service.categoryName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (service.weightBased) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.scale,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
          if (service.durationDisplay != null) ...[
            const SizedBox(width: 8),
            Text(
              service.durationDisplay!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      onTap: () => ServiceDetailRoute(id: service.id).go(context),
    );
  }
}
