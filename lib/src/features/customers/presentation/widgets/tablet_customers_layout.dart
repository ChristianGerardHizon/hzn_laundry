import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/customers_controller.dart';
import 'customer_list_panel.dart';

/// Two-pane tablet layout for customers.
///
/// Left pane: Customer list with search
/// Right pane: Customer detail from router or empty state
class TabletCustomersLayout extends ConsumerWidget {
  const TabletCustomersLayout({
    super.key,
    required this.detailContent,
  });

  /// The detail panel content from the router.
  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersControllerProvider);

    // Get selected customer ID from current route
    final routerState = GoRouterState.of(context);
    final selectedCustomerId = routerState.pathParameters['id'];

    return customersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(customersControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (customers) => Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: CustomerListPanel(customers: customers),
          ),
          const VerticalDivider(width: 1),
          // Detail panel from router
          Expanded(
            child: selectedCustomerId != null
                ? detailContent
                : const _EmptyCustomerState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyCustomerState extends StatelessWidget {
  const _EmptyCustomerState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a customer to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
