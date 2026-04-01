import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';

/// Bottom navigation bar for mobile layout.
///
/// Displays 4 primary navigation destinations:
/// - Dashboard (Home)
/// - Cashier
/// - Products
/// - More (opens drawer for additional options)
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onMoreTap,
  });

  /// Currently selected navigation index.
  final int selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Callback when "More" is tapped to open the drawer.
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return NavigationBar(
      selectedIndex: selectedIndex < 3 ? selectedIndex : 3,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 60,
      onDestinationSelected: (index) {
        if (index == 3) {
          // "More" tapped - open drawer
          onMoreTap?.call();
        } else {
          onDestinationSelected(index);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: t.navigation.dashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.point_of_sale_outlined),
          selectedIcon: const Icon(Icons.point_of_sale),
          label: t.navigation.sales,
        ),
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: t.navigation.salesHistory,
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: const Icon(Icons.more_horiz),
          label: t.navigation.more,
        ),
      ],
    );
  }
}
