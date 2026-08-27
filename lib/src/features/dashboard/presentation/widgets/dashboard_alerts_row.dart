import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../controllers/incomplete_orders_controller.dart';
import 'attendance_alert_section.dart';
import 'needs_attention_alert.dart';

/// Side-by-side warning banners for attendance and incomplete orders.
///
/// On tablet/desktop both alerts share one row. On mobile they stack.
/// Hidden banners do not leave an empty column.
class DashboardAlertsRow extends ConsumerWidget {
  const DashboardAlertsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAttendance = watchShowAttendanceAlert(ref);
    final incomplete = ref.watch(incompleteOrdersProvider).value;
    final showNeeds = incomplete != null && incomplete.hasIssues;

    if (!showAttendance && !showNeeds) return const SizedBox.shrink();

    final alerts = <Widget>[
      if (showAttendance)
        const AttendanceAlertSection(includePadding: false),
      if (showNeeds && incomplete != null)
        NeedsAttentionAlert(data: incomplete),
    ];

    final sideBySide =
        Breakpoints.isTabletOrLarger(context) && alerts.length > 1;

    final content = sideBySide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < alerts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: alerts[i]),
                ],
              ],
            ),
          )
        : Column(
            children: [
              for (var i = 0; i < alerts.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                alerts[i],
              ],
            ],
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: content,
    );
  }
}
