import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../controllers/services_controller.dart';
import '../widgets/service_list_panel.dart';

/// Services list page for mobile view.
class ServicesListPage extends ConsumerWidget {
  const ServicesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesControllerProvider);

    return servicesAsync.when(
      data: (services) => ServiceListPanel(services: services),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(servicesControllerProvider),
      )
    );
  }
}
