import 'package:flutter/material.dart';

import '../../../../core/i18n/strings.g.dart';

/// Super Admin sections shown in the side nav.
enum SuperAdminSection {
  dashboard,
  packages,
  payments,
  billing,
}

const kSuperAdminBrandTeal = Color(0xFF45A9AB);
const kSuperAdminMuted = Color(0xFF9CA3AF);
const kSuperAdminSurface = Color(0xFF141414);
const kSuperAdminSurfaceBorder = Color(0xFF2A2A2A);

/// Vertical navigation panel for Super Admin sections.
class SuperAdminNavPanel extends StatelessWidget {
  const SuperAdminNavPanel({
    super.key,
    required this.currentSection,
    required this.onSectionChanged,
    this.expanded = false,
  });

  final SuperAdminSection currentSection;
  final ValueChanged<SuperAdminSection> onSectionChanged;

  /// When true (e.g. in a mobile drawer), use full-width list rows.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    final items = [
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
      (
        SuperAdminSection.billing,
        Icons.receipt_long_outlined,
        Icons.receipt_long,
        t.subscriptions.tabBilling,
      ),
    ];

    if (expanded) {
      return ColoredBox(
        color: kSuperAdminSurface,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final item in items)
              ListTile(
                leading: Icon(
                  currentSection == item.$1 ? item.$3 : item.$2,
                  color: currentSection == item.$1
                      ? kSuperAdminBrandTeal
                      : kSuperAdminMuted,
                ),
                title: Text(
                  item.$4,
                  style: TextStyle(
                    color: currentSection == item.$1
                        ? kSuperAdminBrandTeal
                        : Colors.white,
                    fontWeight: currentSection == item.$1
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
                selected: currentSection == item.$1,
                selectedTileColor:
                    kSuperAdminBrandTeal.withValues(alpha: 0.14),
                onTap: () => onSectionChanged(item.$1),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 88,
      child: ColoredBox(
        color: kSuperAdminSurface,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 28,
                color: kSuperAdminBrandTeal,
              ),
            ),
            const Divider(color: kSuperAdminSurfaceBorder, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    _NavButton(
                      icon: items[i].$2,
                      selectedIcon: items[i].$3,
                      label: items[i].$4,
                      isSelected: currentSection == items[i].$1,
                      onTap: () => onSectionChanged(items[i].$1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kSuperAdminBrandTeal.withValues(alpha: 0.18)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected ? kSuperAdminBrandTeal : kSuperAdminMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? kSuperAdminBrandTeal : kSuperAdminMuted,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
