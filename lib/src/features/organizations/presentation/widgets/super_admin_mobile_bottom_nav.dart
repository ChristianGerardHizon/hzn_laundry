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
      height: 60,
      backgroundColor: kSuperAdminSurface,
      indicatorColor: kSuperAdminBrandTeal.withValues(alpha: 0.18),
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
            icon: Icon(item.$2, color: kSuperAdminMuted),
            selectedIcon: Icon(item.$3, color: kSuperAdminBrandTeal),
            label: item.$4,
          ),
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz, color: kSuperAdminMuted),
          selectedIcon:
              const Icon(Icons.more_horiz, color: kSuperAdminBrandTeal),
          label: t.navigation.more,
        ),
      ],
    );
  }
}
