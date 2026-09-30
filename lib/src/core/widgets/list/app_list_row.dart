import 'package:flutter/material.dart';

/// Standard list row: 8dp gutter, rounded selection highlight, two-line body.
///
/// Shared by every list panel so rows look and behave the same. Selection uses
/// `secondaryContainer` (rounded) and bolds the title; the trailing slot takes
/// chips / badges / chevrons.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: leading,
        title: DefaultTextStyle.merge(
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: title,
        ),
        subtitle: subtitle == null
            ? null
            : DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: subtitle!,
              ),
        trailing: trailing,
        selected: isSelected,
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

/// Small tonal chip for roles / categories / statuses in a row's trailing slot.
///
/// Pass [color] (e.g. green for paid) to tint; defaults to a neutral surface.
/// Text always uses a foreground derived from the background so contrast holds
/// in both themes.
class RowChip extends StatelessWidget {
  const RowChip({
    super.key,
    required this.label,
    this.color,
    this.maxWidth = 120,
  });

  final String label;
  final Color? color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color background;
    final Color foreground;
    if (color == null) {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
    } else {
      // Blend the tint into the surface, then use onSurface for text so the
      // label stays >= 4.5:1 on light and dark; the dot carries the hue.
      background = Color.alphaBlend(
        color!.withValues(alpha: 0.18),
        scheme.surfaceContainerHighest,
      );
      foreground = scheme.onSurface;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
