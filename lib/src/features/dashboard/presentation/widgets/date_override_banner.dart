import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/dashboard_date_override_provider.dart';

/// Compact past-date chip that sits beside the selected date.
class DateOverrideBanner extends ConsumerWidget {
  const DateOverrideBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverridden = ref.watch(isDashboardDateOverriddenProvider);
    if (!isOverridden) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fgColor = isDark ? Colors.amber.shade200 : Colors.amber.shade900;
    final bgColor = isDark
        ? Colors.amber.shade900.withValues(alpha: 0.35)
        : Colors.amber.shade50;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'New sales will be posted to this date',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 14, color: fgColor),
                const SizedBox(width: 4),
                Text(
                  'Past date',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            ref.read(dashboardDateOverrideProvider.notifier).clearOverride();
          },
          style: TextButton.styleFrom(
            foregroundColor: fgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(44, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
