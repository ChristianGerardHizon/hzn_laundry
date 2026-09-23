import 'package:flutter/material.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_system_layout.dart';

/// Adaptive shell for system/settings list/detail layout.
///
/// - Mobile: Passes through the child (list or detail page)
/// - Tablet: Shows two-pane layout with list and detail side by side
class SystemShell extends StatelessWidget {
  const SystemShell({
    super.key,
    required this.child,
  });

  /// The child widget from the router (detail page or placeholder).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isMultiColumnOrLarger(context);

    if (isTablet) {
      // Tablet: Two-pane layout with list always visible
      return TabletSystemLayout(detailChild: child);
    }

    // Mobile: Just show the routed child (list or detail)
    return child;
  }
}
