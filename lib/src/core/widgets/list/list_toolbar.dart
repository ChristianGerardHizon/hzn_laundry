import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';

/// Minimum touch target for toolbar actions (Material / WCAG 2.5.5).
const double kListToolbarTarget = 44;

/// Single-row search + actions toolbar shared by list screens.
///
/// - Idle: filled search field with optional filter / sort actions.
/// - Search active ([activeQuery] != null): the field becomes a dismissible
///   query chip so users can see what is applied and clear it in one tap.
///
/// The filter action shows a count badge only when [filterCount] > 0.
class ListToolbar extends StatelessWidget {
  const ListToolbar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onTextChanged,
    this.hintText,
    this.activeQuery,
    this.onClear,
    this.onFilterPressed,
    this.filterCount = 0,
    this.onSortPressed,
    this.sortDescending,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final String? hintText;

  /// Non-null while a server-side search is applied.
  final String? activeQuery;
  final VoidCallback? onClear;

  final VoidCallback? onFilterPressed;
  final int filterCount;

  final VoidCallback? onSortPressed;
  final bool? sortDescending;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: activeQuery != null
                ? _ActiveQuery(
                    query: activeQuery!,
                    filterCount: filterCount,
                    onClear: onClear,
                  )
                : _SearchField(
                    controller: controller,
                    hintText: hintText ?? '${t.common.search}...',
                    onSearch: onSearch,
                    onTextChanged: onTextChanged,
                  ),
          ),
          if (onSortPressed != null) ...[
            const SizedBox(width: 8),
            _ToolbarAction(
              icon: (sortDescending ?? true)
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              tooltip: t.common.sort,
              onPressed: onSortPressed!,
            ),
          ],
          if (onFilterPressed != null) ...[
            const SizedBox(width: 8),
            _ToolbarAction(
              icon: Icons.tune,
              tooltip: t.common.filter,
              badgeCount: filterCount,
              onPressed: onFilterPressed!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.onTextChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = Translations.of(context);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(kListToolbarTarget / 2),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      height: kListToolbarTarget,
      child: TextField(
        controller: controller,
        onChanged: onTextChanged,
        onSubmitted: (_) => onSearch(),
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          prefixIcon: const Icon(Icons.search, size: 22),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: t.common.cancel,
                    onPressed: () {
                      controller.clear();
                      onTextChanged('');
                    },
                  ),
          ),
          filled: true,
          fillColor: scheme.surfaceContainerHigh,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: border(Colors.transparent),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(scheme.primary, 1.5),
        ),
      ),
    );
  }
}

class _ActiveQuery extends StatelessWidget {
  const _ActiveQuery({
    required this.query,
    required this.filterCount,
    required this.onClear,
  });

  final String query;
  final int filterCount;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.secondaryContainer,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onClear,
        child: SizedBox(
          height: kListToolbarTarget,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: scheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$query"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (filterCount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$filterCount',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.close,
                  size: 20,
                  semanticLabel: Translations.of(context).common.cancel,
                  color: scheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = IconButton.filledTonal(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(kListToolbarTarget),
        minimumSize: const Size.square(kListToolbarTarget),
      ),
    );

    if (badgeCount <= 0) return button;
    return Badge(label: Text('$badgeCount'), child: button);
  }
}
