import 'package:flutter/material.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';

export 'super_admin_theme.dart';

/// Super Admin sections shown in the side nav.
enum SuperAdminSection {
  dashboard,
  packages,
  payments,
  billing,
  appearance,
}

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
    final scheme = Theme.of(context).colorScheme;

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
      (
        SuperAdminSection.appearance,
        Icons.palette_outlined,
        Icons.palette,
        'Appearance',
      ),
    ];

    if (expanded) {
      return ColoredBox(
        color: scheme.surfaceContainerLow,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  minTileHeight: 52,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    currentSection == item.$1 ? item.$3 : item.$2,
                    color: currentSection == item.$1
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  title: Text(
                    item.$4,
                    style: TextStyle(
                      color: currentSection == item.$1
                          ? scheme.primary
                          : scheme.onSurface,
                      fontWeight: currentSection == item.$1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  selected: currentSection == item.$1,
                  selectedTileColor: scheme.primary.withValues(alpha: 0.16),
                  onTap: () => onSectionChanged(item.$1),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 88,
      child: ColoredBox(
        color: scheme.surfaceContainerLow,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Assets.icons.appIconTransparent.image(width: 36, height: 36),
            const SizedBox(height: 16),
            Divider(color: scheme.outlineVariant, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
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
    final scheme = Theme.of(context).colorScheme;
    final color = isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Center(
          child: Material(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isSelected ? selectedIcon : icon,
                        size: 24, color: color),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
