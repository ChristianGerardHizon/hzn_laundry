import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import 'nav_permissions.dart';

/// Bottom navigation bar for mobile layout.
///
/// Shows up to 3 primary visible items + "More" button to open drawer.
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.visibleItems,
    this.onMoreTap,
  });

  /// Currently selected navigation index (within visible items).
  final int selectedIndex;

  /// Callback when a destination is selected (visible index).
  final ValueChanged<int> onDestinationSelected;

  /// Permission-filtered navigation items.
  final List<NavItem> visibleItems;

  /// Callback when "More" is tapped to open the drawer.
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    // Show first 3 visible items + More
    final bottomItems = visibleItems.take(3).toList();

    return NavigationBar(
      selectedIndex: selectedIndex < bottomItems.length
          ? selectedIndex
          : bottomItems.length,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 60,
      onDestinationSelected: (index) {
        if (index == bottomItems.length) {
          // "More" tapped - open drawer
          onMoreTap?.call();
        } else {
          onDestinationSelected(index);
        }
      },
      destinations: [
        ...bottomItems.map((item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            )),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: const Icon(Icons.more_horiz),
          label: t.navigation.more,
        ),
      ],
    );
  }
}
