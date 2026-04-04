import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_employees_layout.dart';

/// Adaptive shell for employees.
///
/// On tablet: Shows two-pane layout with list and detail
/// On mobile: Shows only the child (list or detail)
class EmployeesShell extends ConsumerWidget {
  const EmployeesShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    return TabletEmployeesLayout(detailContent: child);
  }
}
