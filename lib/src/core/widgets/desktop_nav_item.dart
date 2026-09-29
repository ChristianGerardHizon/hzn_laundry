import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A single sidebar row with optional pill highlight for the active route.
class DesktopNavItem extends StatelessWidget {
  const DesktopNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.collapsed = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Secondary action for touch users (used to toggle pins).
  final VoidCallback? onLongPress;
  final bool collapsed;
  final Widget? trailing;

  static const double expandedHeight = 40;
  static const double collapsedSize = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: collapsed ? collapsedSize : expandedHeight,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
          ),
          decoration: BoxDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: collapsed
              ? Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(message: label, child: content);
    }
    return content;
  }
}

/// Muted section header for sidebar groups.
class DesktopNavSectionHeader extends StatelessWidget {
  const DesktopNavSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Aligned with item icons and [DesktopNavGroupHeader] text.
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// [DesktopNavItem] with a pin/unpin action.
///
/// The pin button appears on hover or keyboard focus (it stays in the focus
/// order but ignores pointer input while hidden so touch taps never pin by
/// accident). Long-press toggles the pin for touch users.
class DesktopPinnableNavItem extends HookWidget {
  const DesktopPinnableNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.pinned,
    required this.onTogglePin,
    required this.pinTooltip,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool pinned;
  final VoidCallback onTogglePin;

  /// Localized "Pin to top" / "Unpin" text matching [pinned].
  final String pinTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hovered = useState(false);
    final focused = useState(false);
    final showPin = hovered.value || focused.value;

    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (value) => focused.value = value,
        child: DesktopNavItem(
          icon: icon,
          label: label,
          selected: selected,
          onTap: onTap,
          onLongPress: onTogglePin,
          trailing: IgnorePointer(
            ignoring: !showPin,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: showPin ? 1 : 0,
              child: SizedBox.square(
                dimension: 28,
                child: IconButton(
                  tooltip: pinTooltip,
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  color: pinned
                      ? colorScheme.primary
                      : selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                  icon: Icon(
                    pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  onPressed: onTogglePin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Collapsible group title. Chevron points down when expanded.
class DesktopNavGroupHeader extends StatelessWidget {
  const DesktopNavGroupHeader({
    super.key,
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.toggleTooltip,
  });

  final String label;
  final bool expanded;
  final VoidCallback onToggle;

  /// Localized "Collapse section" / "Expand section".
  final String toggleTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      child: Tooltip(
        message: toggleTooltip,
        child: Semantics(
          button: true,
          expanded: expanded,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        turns: expanded ? 0 : -0.25,
                        child: Icon(Icons.expand_more, size: 18, color: color),
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
