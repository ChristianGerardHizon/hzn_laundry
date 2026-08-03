import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/i18n/strings.g.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_format.dart';
import '../../settings/presentation/controllers/current_branch_controller.dart';
import '../domain/pos_group.dart';
import 'cart_controller.dart';
import 'components/cart_view.dart';
import 'components/cashier_search_dropdown.dart';
import 'components/grouped_cashier_view.dart';
import 'components/product_grid.dart';
import 'components/service_grid.dart';
import 'controllers/pos_groups_controller.dart';

class PosScreen extends HookConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    // Watch POS groups for the current branch
    final posGroupsAsync = ref.watch(posGroupsControllerProvider);
    final groups = posGroupsAsync.value ?? [];
    final hasGroups = groups.isNotEmpty;
    final isAllBranches = ref.watch(isAllBranchesProvider);

    final isMobile = Breakpoints.isMobile(context);

    final content = isMobile
        ? _MobileLayout(
            scaffoldKey: scaffoldKey,
            hasGroups: hasGroups,
            groups: groups,
          )
        : _DesktopLayout(
            hasGroups: hasGroups,
            groups: groups,
          );

    if (!isAllBranches) return content;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: content,
        ),
        const Positioned.fill(
          child: _AllBranchesPosOverlay(),
        ),
      ],
    );
  }
}

class _AllBranchesPosOverlay extends StatelessWidget {
  const _AllBranchesPosOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(
          color: theme.colorScheme.scrim.withValues(alpha: 0.45),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.navigation.allBranches,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.navigation.posUnavailableAllBranches,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.hasGroups,
    required this.groups,
  });

  final bool hasGroups;
  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier'),
      ),
      body: Row(
        children: [
          // Product/Service Grid Area
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Search dropdown (always shown)
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: CashierSearchDropdown(),
                ),
                const SizedBox(height: 12),
                if (hasGroups)
                  Expanded(
                    child: GroupedCashierView(groups: groups),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Services',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const Expanded(
                    child: ServiceGrid(),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Products',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const Expanded(
                    child: ProductGrid(),
                  ),
                ],
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Cart Area
          Expanded(
            flex: 4,
            child: Container(
              color: theme.colorScheme.surfaceContainerLowest,
              child: const CartView(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.scaffoldKey,
    required this.hasGroups,
    required this.groups,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool hasGroups;
  final List<PosGroup> groups;

  void _showCartSheet(BuildContext context) {
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cart',
      barrierColor: Colors.black54,
      useRootNavigator: true, // Renders above bottom nav bar
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: theme.colorScheme.surface,
            elevation: 16,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SafeArea(
                child: Column(
                  children: [
                    // Drawer header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cart',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cart content
                    const Expanded(child: CartView()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0), // Slide from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartControllerProvider);
    final itemCount = cartState.value?.totalItemCount ?? 0;
    final total = cartState.value?.total ?? 0;

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Cashier'),
        actions: [
          // Cart button in app bar
          IconButton(
            onPressed: () => _showCartSheet(context),
            icon: Badge(
              isLabelVisible: itemCount > 0,
              label: Text('$itemCount'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search dropdown (always shown)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CashierSearchDropdown(isDense: true),
          ),
          if (hasGroups)
            Expanded(
              child: GroupedCashierView(groups: groups),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Services',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const Expanded(
              child: ServiceGrid(),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Products',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const Expanded(
              child: ProductGrid(),
            ),
          ],
        ],
      ),
      // FAB to open cart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCartSheet(context),
        icon: Badge(
          isLabelVisible: itemCount > 0,
          label: Text('$itemCount'),
          child: const Icon(Icons.shopping_cart),
        ),
        label: Text(total.toCurrency()),
      ),
    );
  }
}
