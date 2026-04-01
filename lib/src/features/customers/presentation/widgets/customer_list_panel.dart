import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/customers.routes.dart';
import '../../domain/customer.dart';
import '../controllers/customers_controller.dart';
import 'customer_form_sheet.dart';

/// List panel for displaying customers with search and create.
class CustomerListPanel extends HookConsumerWidget {
  const CustomerListPanel({
    super.key,
    required this.customers,
  });

  final List<Customer> customers;

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

    final filteredCustomers = searchQuery.value.isEmpty
        ? customers
        : customers.where((c) {
            final query = searchQuery.value.toLowerCase();
            return c.name.toLowerCase().contains(query) ||
                (c.phone?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(customersControllerProvider.notifier).refresh(),
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
                hintText: 'Search customers...',
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

          // Customers list
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No customers yet'
                              : 'No customers match "${searchQuery.value}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(customersControllerProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return _CustomerListTile(customer: customer);
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

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showCustomerFormDialog(context);
  }
}

class _CustomerListTile extends StatelessWidget {
  const _CustomerListTile({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(customer.name),
      subtitle: customer.phone != null && customer.phone!.isNotEmpty
          ? Text(
              customer.phone!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: () => CustomerDetailRoute(id: customer.id).go(context),
    );
  }
}
