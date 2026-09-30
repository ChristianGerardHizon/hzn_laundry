import 'package:flutter/material.dart';

/// An overflow-menu entry for [DetailAppBar].
class DetailMenuItem {
  const DetailMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
  });

  final String value;
  final String label;
  final IconData icon;

  /// Draws the entry in the error color (e.g. Delete).
  final bool destructive;
}

/// Standard app bar for entity detail pages.
///
/// - Title is the entity name with an optional one-line [subtitle] (e.g. role).
/// - Only the primary action ([onEdit]) stays visible; Refresh and the page's
///   other actions live in one overflow menu, so the title gets the room.
/// - Tabs fill the width when there are 3 or fewer, and scroll (start-aligned)
///   beyond that. Four fill-width tabs truncate labels like "Adjustments" at
///   360dp, so 4+ tabs scroll instead.
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.onEdit,
    this.editTooltip = 'Edit',
    this.onRefresh,
    this.menuItems = const [],
    this.onMenuSelected,
    this.tabController,
    this.tabs,
  });

  final String title;
  final String? subtitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  final VoidCallback? onEdit;
  final String editTooltip;

  /// Adds a "Refresh" entry at the top of the overflow menu.
  final VoidCallback? onRefresh;

  final List<DetailMenuItem> menuItems;
  final ValueChanged<String>? onMenuSelected;

  final TabController? tabController;
  final List<Tab>? tabs;

  static const _refreshValue = '__refresh__';

  /// Most tabs that still fit full-width on a 360dp phone.
  static const maxFillTabs = 3;

  bool get _hasTabs => tabs != null && tabs!.isNotEmpty;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (_hasTabs ? kTextTabBarHeight : 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasMenu = onRefresh != null || menuItems.isNotEmpty;

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: editTooltip,
            onPressed: onEdit,
          ),
        if (hasMenu)
          PopupMenuButton<String>(
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            onSelected: (value) {
              if (value == _refreshValue) {
                onRefresh?.call();
              } else {
                onMenuSelected?.call(value);
              }
            },
            itemBuilder: (context) => [
              if (onRefresh != null)
                const PopupMenuItem(
                  value: _refreshValue,
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Refresh'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              for (final item in menuItems)
                PopupMenuItem(
                  value: item.value,
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.destructive ? scheme.error : null,
                    ),
                    title: Text(
                      item.label,
                      style: item.destructive
                          ? TextStyle(color: scheme.error)
                          : null,
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        const SizedBox(width: 4),
      ],
      bottom: _hasTabs
          ? TabBar(
              controller: tabController,
              isScrollable: tabs!.length > maxFillTabs,
              tabAlignment: tabs!.length > maxFillTabs
                  ? TabAlignment.start
                  : TabAlignment.fill,
              tabs: tabs!,
            )
          : null,
    );
  }
}
