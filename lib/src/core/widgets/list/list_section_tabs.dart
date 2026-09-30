import 'package:flutter/material.dart';

/// One option in [ListSectionTabs].
class ListSectionTab<T> {
  const ListSectionTab({
    required this.value,
    required this.label,
    this.count,
    this.highlightCount = false,
  });

  final T value;
  final String label;

  /// Shown after the label when non-null.
  final int? count;

  /// When true the count is drawn as an attention badge (e.g. pending
  /// invites) instead of plain text.
  final bool highlightCount;
}

/// Compact segmented tabs with inline counts (e.g. `Members 12 | Invites 2`).
///
/// Replaces a full-width [SegmentedButton] that used icons + a separate
/// "N total" line: counts live in the label so no extra row is needed.
class ListSectionTabs<T> extends StatelessWidget {
  const ListSectionTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 4),
  });

  final List<ListSectionTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<T>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(0, 44),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          segments: [
            for (final tab in tabs)
              ButtonSegment<T>(
                value: tab.value,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(tab.label, overflow: TextOverflow.ellipsis),
                    ),
                    if (tab.count != null) ...[
                      const SizedBox(width: 8),
                      tab.highlightCount && tab.count! > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tab.count}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onError,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Text(
                              '${tab.count}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                    ],
                  ],
                ),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (next) => onChanged(next.first),
        ),
      ),
    );
  }
}
