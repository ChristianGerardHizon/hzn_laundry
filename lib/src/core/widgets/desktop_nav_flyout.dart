import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../navigation/desktop_nav_presentation.dart';
import 'desktop_nav_item.dart';

/// Optional footer action at the bottom of a [DesktopNavFlyout] panel.
class DesktopNavFlyoutFooter {
  const DesktopNavFlyoutFooter({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Hover/tap flyout panel listing destinations within a sidebar category.
class DesktopNavFlyout extends StatelessWidget {
  const DesktopNavFlyout({
    super.key,
    required this.category,
    required this.destinations,
    required this.selectedKey,
    required this.onDestinationTap,
    this.footer,
  });

  final AppNavCategory category;
  final List<DesktopFlyoutDestination> destinations;
  final Object selectedKey;
  final ValueChanged<DesktopFlyoutDestination> onDestinationTap;
  final DesktopNavFlyoutFooter? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = Translations.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  appNavCategoryLabel(category, t),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final dest in destinations)
                _FlyoutItem(
                  icon: dest.selectionKey == selectedKey
                      ? dest.selectedIcon
                      : dest.icon,
                  label: dest.label,
                  selected: dest.selectionKey == selectedKey,
                  onTap: () => onDestinationTap(dest),
                ),
              if (footer != null) ...[
                if (destinations.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Divider(height: 1),
                  ),
                _FlyoutItem(
                  icon: footer!.icon,
                  label: footer!.label,
                  selected: false,
                  onTap: footer!.onTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyoutItem extends StatelessWidget {
  const _FlyoutItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: selected ? colorScheme.secondaryContainer : null,
          child: Row(
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
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category row that opens [DesktopNavFlyout] on hover (expanded) or tap (collapsed).
class DesktopNavCategoryRow extends StatefulWidget {
  const DesktopNavCategoryRow({
    super.key,
    required this.category,
    required this.destinations,
    required this.selectedKey,
    required this.selected,
    required this.collapsed,
    required this.onDestinationTap,
    this.footer,
  });

  final AppNavCategory category;
  final List<DesktopFlyoutDestination> destinations;
  final Object selectedKey;
  final bool selected;
  final bool collapsed;
  final ValueChanged<DesktopFlyoutDestination> onDestinationTap;
  final DesktopNavFlyoutFooter? footer;

  @override
  State<DesktopNavCategoryRow> createState() => _DesktopNavCategoryRowState();
}

class _DesktopNavCategoryRowState extends State<DesktopNavCategoryRow> {
  final _anchorKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  bool get _canShowOverlay =>
      widget.destinations.isNotEmpty || widget.footer != null;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null || !_canShowOverlay) return;

    final renderBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideOverlay,
            ),
          ),
          Positioned(
            left: anchorOffset.dx + anchorSize.width + 4,
            top: anchorOffset.dy,
            child: MouseRegion(
              onEnter: (_) => _isHovered = true,
              onExit: (_) {
                _isHovered = false;
                Future<void>.delayed(const Duration(milliseconds: 120), () {
                  if (!_isHovered && mounted) _hideOverlay();
                });
              },
              child: DesktopNavFlyout(
                category: widget.category,
                destinations: widget.destinations,
                selectedKey: widget.selectedKey,
                footer: widget.footer == null
                    ? null
                    : DesktopNavFlyoutFooter(
                        icon: widget.footer!.icon,
                        label: widget.footer!.label,
                        onTap: () {
                          _hideOverlay();
                          widget.footer!.onTap();
                        },
                      ),
                onDestinationTap: (dest) {
                  _hideOverlay();
                  widget.onDestinationTap(dest);
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _removeOverlay();
    setState(() => _isHovered = false);
  }

  void _onHoverEnter() {
    if (widget.collapsed) return;
    _isHovered = true;
    _showOverlay();
  }

  void _onHoverExit() {
    if (widget.collapsed) return;
    _isHovered = false;
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!_isHovered && mounted) _hideOverlay();
    });
  }

  void _onTap() {
    if (widget.collapsed) {
      _showOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final label = appNavCategoryLabel(widget.category, t);

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: KeyedSubtree(
        key: _anchorKey,
        child: DesktopNavItem(
          icon: appNavCategoryIcon(widget.category),
          label: label,
          selected: widget.selected,
          onTap: _onTap,
          collapsed: widget.collapsed,
          trailing: widget.collapsed
              ? null
              : Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
