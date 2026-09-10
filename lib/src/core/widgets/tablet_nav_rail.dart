import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import '../utils/breakpoints.dart';
import 'nav_permissions.dart';
import 'network_health_logo.dart';

/// Navigation rail for tablet layouts (600–899px).
///
/// Displays permission-filtered navigation destinations with icons.
/// For tablet-large and desktop (>=900px), `AppRoot` uses `DesktopSideNav`.
class TabletNavRail extends ConsumerWidget {
  const TabletNavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.visibleItems,
  });

  /// Currently selected navigation index (within visible items).
  final int selectedIndex;

  /// Callback when a destination is selected (visible index).
  final ValueChanged<int> onDestinationSelected;

  /// Permission-filtered navigation items.
  final List<NavItem> visibleItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isLargeTablet = Breakpoints.isTabletLargeOrLarger(context);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: NetworkHealthLogo(size: 40),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: isLargeTablet
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.selected,
                destinations: visibleItems
                    .map((item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: t.auth.logoutButton,
            onPressed: () => _confirmLogout(context, ref, t),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, Translations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.auth.logoutButton),
        content: Text(t.auth.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}
