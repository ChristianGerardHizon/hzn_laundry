import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_customers_layout.dart';

/// Adaptive shell for customers.
///
/// On tablet: Shows two-pane layout with list and detail
/// On mobile: Shows only the child (list or detail)
class CustomersShell extends ConsumerWidget {
  const CustomersShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On mobile, just show the child directly
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    // On tablet, use two-pane layout
    return TabletCustomersLayout(detailContent: child);
  }
}
