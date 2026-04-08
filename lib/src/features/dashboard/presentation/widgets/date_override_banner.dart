import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_date_override_provider.dart';

/// Warning banner shown when the dashboard date is overridden.
/// Displays the selected date and a button to reset to today.
class DateOverrideBanner extends ConsumerWidget {
  const DateOverrideBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverridden = ref.watch(isDashboardDateOverriddenProvider);
    if (!isOverridden) return const SizedBox.shrink();

    final effectiveDate = ref.watch(dashboardEffectiveDateProvider);
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade50;
    final fgColor = isDark ? Colors.amber.shade200 : Colors.amber.shade900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 20,
            color: fgColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Viewing ${DateFormat('MMMM d, yyyy').format(effectiveDate)}. '
              'New sales will be posted to this date.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: fgColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              ref
                  .read(dashboardDateOverrideProvider.notifier)
                  .clearOverride();
            },
            icon: const Icon(Icons.today, size: 16),
            label: const Text('Reset to Today'),
            style: TextButton.styleFrom(
              foregroundColor: fgColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
