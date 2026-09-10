import 'package:flutter/material.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_management_layout.dart';

/// Adaptive shell for organization 3-panel layout.
///
/// - Mobile: Passes through the child (list or detail page)
/// - Tablet: Shows 3-panel layout (nav + list + detail)
class ManagementShell extends StatelessWidget {
  const ManagementShell({
    super.key,
    required this.child,
  });

  /// The child widget from the router (detail page or placeholder).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTabletOrLarger(context);

    if (isTablet) {
      // Tablet: 3-panel layout
      return TabletManagementLayout(detailChild: child);
    }

    // Mobile: Just show the routed child (list or detail)
    return child;
  }
}
