import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_promos_layout.dart';

/// Adaptive shell for promos.
///
/// On tablet: Shows two-pane layout with list and detail
/// On mobile: Shows only the child (list or detail)
class PromosShell extends ConsumerWidget {
  const PromosShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    return TabletPromosLayout(detailContent: child);
  }
}
