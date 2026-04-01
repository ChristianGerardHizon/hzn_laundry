import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/services_controller.dart';
import 'service_list_panel.dart';

/// Two-pane tablet layout for services.
///
/// Left pane: Service list with search
/// Right pane: Service detail from router or empty state
class TabletServicesLayout extends ConsumerWidget {
  const TabletServicesLayout({
    super.key,
    required this.detailContent,
  });

  /// The detail panel content from the router.
  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesControllerProvider);

    // Get selected service ID from current route
    final routerState = GoRouterState.of(context);
    final selectedServiceId = routerState.pathParameters['id'];

    return servicesAsync.when(
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
                  ref.read(servicesControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (services) => Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: ServiceListPanel(services: services),
          ),
          const VerticalDivider(width: 1),
          // Detail panel from router
          Expanded(
            child: selectedServiceId != null
                ? detailContent
                : const _EmptyServiceState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyServiceState extends StatelessWidget {
  const _EmptyServiceState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.miscellaneous_services,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a service to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
