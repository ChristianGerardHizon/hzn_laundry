import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

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
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(customersControllerProvider),
      )
    );
  }
}
