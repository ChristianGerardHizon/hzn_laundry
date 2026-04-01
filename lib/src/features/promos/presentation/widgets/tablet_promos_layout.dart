import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/promos_controller.dart';
import 'promo_list_panel.dart';

/// Two-pane tablet layout for promos.
///
/// Left pane: Promo list with search
/// Right pane: Promo detail from router or empty state
class TabletPromosLayout extends ConsumerWidget {
  const TabletPromosLayout({
    super.key,
    required this.detailContent,
  });

  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(promosControllerProvider);

    final routerState = GoRouterState.of(context);
    final selectedPromoId = routerState.pathParameters['id'];

    return promosAsync.when(
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
                  ref.read(promosControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (promos) => Row(
        children: [
          SizedBox(
            width: 320,
            child: PromoListPanel(promos: promos),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedPromoId != null
                ? detailContent
                : const _EmptyPromoState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyPromoState extends StatelessWidget {
  const _EmptyPromoState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.loyalty,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a promo to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
