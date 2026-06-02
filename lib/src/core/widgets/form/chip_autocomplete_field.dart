import 'package:flutter/material.dart';

/// A search bar with chip display for multi-select.
///
/// Selected items render as [InputChip]s above a search [TextField].
/// Typing filters a suggestion list below the field.
class ChipAutocompleteField<T extends Object> extends StatefulWidget {
  const ChipAutocompleteField({
    super.key,
    required this.selectedItems,
    required this.onChanged,
    required this.allItems,
    required this.labelBuilder,
    required this.filterCallback,
    this.chipAvatar,
    this.enabled = true,
    this.suggestedItems,
    this.itemTypeSingular = 'item',
    this.itemTypePlural = 'items',
  });

  final List<T> selectedItems;
  final ValueChanged<List<T>> onChanged;
  final List<T> allItems;
  final String Function(T item) labelBuilder;
  final bool Function(T item, String query) filterCallback;
  final Widget Function(T item)? chipAvatar;
  final bool enabled;

  /// Items to prioritize at the top of the list when there is no search query.
  final List<T>? suggestedItems;

  /// Singular label used in placeholder copy (e.g. "service", "treatment").
  final String itemTypeSingular;

  /// Plural label used in placeholder copy (e.g. "services", "treatments").
  final String itemTypePlural;

  @override
  State<ChipAutocompleteField<T>> createState() =>
      _ChipAutocompleteFieldState<T>();
}

class _ChipAutocompleteFieldState<T extends Object>
    extends State<ChipAutocompleteField<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _available =>
      widget.allItems.where((t) => !widget.selectedItems.contains(t)).toList();

  /// Splits available items into suggested and remaining lists.
  /// Returns (suggested, remaining, total display list).
  ({List<T> suggested, List<T> remaining}) _buildSuggestedDisplay(
      List<T> available) {
    final suggestions = widget.suggestedItems;
    if (suggestions == null || suggestions.isEmpty) {
      return (suggested: <T>[], remaining: available);
    }
    final suggested =
        suggestions.where((t) => available.contains(t)).toList();
    final remaining =
        available.where((t) => !suggested.contains(t)).toList();
    return (suggested: suggested, remaining: remaining);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = _available;
    final hasQuery = _query.isNotEmpty;

    final filteredSuggestions = hasQuery
        ? available.where((t) => widget.filterCallback(t, _query)).take(10).toList()
        : <T>[];

    // When no query, build suggested + remaining display
    final suggestedDisplay = !hasQuery ? _buildSuggestedDisplay(available) : null;
    final hasSuggestions =
        suggestedDisplay != null && suggestedDisplay.suggested.isNotEmpty;

    final showAllAvailable = !hasQuery && available.length <= 10;
    final displayList = hasQuery
        ? filteredSuggestions
        : (showAllAvailable
            ? available
            : (hasSuggestions
                ? [
                    ...suggestedDisplay.suggested,
                    ...suggestedDisplay.remaining
                        .take(10 - suggestedDisplay.suggested.length),
                  ]
                : <T>[]));
    final suggestedCount =
        hasSuggestions ? suggestedDisplay.suggested.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected items as chips
        if (widget.selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.selectedItems.map((item) {
                return InputChip(
                  label: Text(
                    widget.labelBuilder(item),
                    style: const TextStyle(fontSize: 13),
                  ),
                  avatar: widget.chipAvatar?.call(item),
                  deleteIconColor: theme.colorScheme.onSurfaceVariant,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onDeleted: widget.enabled
                      ? () {
                          final updated = [...widget.selectedItems]..remove(item);
                          widget.onChanged(updated);
                        }
                      : null,
                );
              }).toList(),
            ),
          ),

        // Search field
        if (widget.enabled && available.isNotEmpty)
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: widget.selectedItems.isEmpty
                  ? '${widget.itemTypePlural[0].toUpperCase()}${widget.itemTypePlural.substring(1)} *'
                  : 'Add more ${widget.itemTypePlural}',
              hintText: 'Type to search...',
              isDense: true,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search, size: 20),
              helperText: !hasQuery && !showAllAvailable
                  ? '${available.length} ${widget.itemTypePlural} available \u2014 type to search'
                  : null,
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),

        // Suggestions list
        if (widget.enabled && displayList.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: displayList.length +
                  (suggestedCount > 0 && !hasQuery ? 1 : 0),
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                // Show "Suggested" header at position 0 when we have suggestions
                if (suggestedCount > 0 && !hasQuery && index == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Suggested',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                final itemIndex =
                    suggestedCount > 0 && !hasQuery ? index - 1 : index;
                final item = displayList[itemIndex];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: widget.chipAvatar?.call(item),
                  title: Text(
                    widget.labelBuilder(item),
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () {
                    final updated = [...widget.selectedItems, item];
                    widget.onChanged(updated);
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                );
              },
            ),
          ),

        if (hasQuery && filteredSuggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No matches for "$_query"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),

        if (widget.enabled &&
            available.isEmpty &&
            widget.selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'All ${widget.itemTypePlural} selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}
