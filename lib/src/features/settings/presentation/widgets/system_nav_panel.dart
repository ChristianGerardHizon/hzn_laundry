import 'package:flutter/material.dart';

/// Device-specific system settings modes.
enum SystemMode {
  printers,
  appearance,
}

/// Vertical navigation panel for selecting system mode.
class SystemNavPanel extends StatelessWidget {
  const SystemNavPanel({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  /// Currently selected mode.
  final SystemMode currentMode;

  /// Callback when mode is changed.
  final ValueChanged<SystemMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.settings,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _NavButton(
            icon: Icons.print_outlined,
            selectedIcon: Icons.print,
            label: 'Printers',
            isSelected: currentMode == SystemMode.printers,
            onTap: () => onModeChanged(SystemMode.printers),
          ),
          const SizedBox(height: 4),
          _NavButton(
            icon: Icons.palette_outlined,
            selectedIcon: Icons.palette,
            label: 'Appearance',
            isSelected: currentMode == SystemMode.appearance,
            onTap: () => onModeChanged(SystemMode.appearance),
          ),
          const Spacer(),
        ],
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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
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
