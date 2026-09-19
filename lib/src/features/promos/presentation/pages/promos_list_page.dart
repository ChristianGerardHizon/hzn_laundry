import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../controllers/promos_controller.dart';
import '../widgets/promo_list_panel.dart';

/// Promos list page for mobile view.
class PromosListPage extends ConsumerWidget {
  const PromosListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(promosControllerProvider);

    return promosAsync.when(
      data: (promos) => PromoListPanel(promos: promos),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(promosControllerProvider),
      )
    );
  }
}
