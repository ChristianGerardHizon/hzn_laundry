import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading services: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(servicesControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
