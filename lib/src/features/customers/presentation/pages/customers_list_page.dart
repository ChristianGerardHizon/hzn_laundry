import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/customers_controller.dart';
import '../widgets/customer_list_panel.dart';

/// Customers list page for mobile view.
class CustomersListPage extends ConsumerWidget {
  const CustomersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersControllerProvider);

    return customersAsync.when(
      data: (customers) => CustomerListPanel(customers: customers),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading customers: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(customersControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
