import 'package:flutter/material.dart';

import '../../../../core/i18n/strings.g.dart';
import 'super_admin_nav_panel.dart';

/// Mobile bottom navigation for Super Admin (mirrors [MobileBottomNav]).
///
/// Shows Dashboard, Packages, Payments + "More" to open the drawer.
class SuperAdminMobileBottomNav extends StatelessWidget {
  const SuperAdminMobileBottomNav({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    this.onMoreTap,
  });

  final SuperAdminSection currentSection;
  final ValueChanged<SuperAdminSection> onSectionSelected;
  final VoidCallback? onMoreTap;

  static const _primarySections = [
    SuperAdminSection.dashboard,
    SuperAdminSection.packages,
    SuperAdminSection.payments,
  ];

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final destinations = [
      (
        SuperAdminSection.dashboard,
        Icons.dashboard_outlined,
        Icons.dashboard,
        t.navigation.dashboard,
      ),
      (
        SuperAdminSection.packages,
        Icons.inventory_2_outlined,
        Icons.inventory_2,
        t.subscriptions.tabPackages,
      ),
      (
        SuperAdminSection.payments,
        Icons.payments_outlined,
        Icons.payments,
        t.subscriptions.tabPayments,
      ),
    ];

    final primaryIndex = _primarySections.indexOf(currentSection);
    final selectedIndex =
        primaryIndex >= 0 ? primaryIndex : destinations.length;

    return NavigationBar(
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 64,
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.16),
      onDestinationSelected: (index) {
        if (index == destinations.length) {
          onMoreTap?.call();
        } else {
          onSectionSelected(destinations[index].$1);
        }
      },
      destinations: [
        ...destinations.map(
          (item) => NavigationDestination(
            icon: Icon(item.$2, color: scheme.onSurfaceVariant),
            selectedIcon: Icon(item.$3, color: scheme.primary),
            label: item.$4,
          ),
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz, color: scheme.onSurfaceVariant),
          selectedIcon: Icon(Icons.more_horiz, color: scheme.primary),
          label: t.navigation.more,
        ),
      ],
    );
  }
}
