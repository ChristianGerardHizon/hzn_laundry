import 'package:flutter/material.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../domain/incomplete_orders.dart';
import 'incomplete_orders_modal.dart';

/// Warning banner for orders missing machines/packs or still processing.
class NeedsAttentionAlert extends StatelessWidget {
  const NeedsAttentionAlert({super.key, required this.data});

  final IncompleteOrdersData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final compact = Breakpoints.isMobile(context);
    final color = Colors.deepOrange;
    final subtitle = [
      if (data.processingCount > 0) '${data.processingCount} processing',
      if (data.missingDataCount > 0) '${data.missingDataCount} missing data',
    ].join(' · ');

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: isDark ? color.shade200 : Colors.deepOrange.shade900,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: isDark ? color.shade100 : Colors.deepOrange.shade800,
    );
    final countLine = '${data.count} order${data.count == 1 ? '' : 's'}'
        '${subtitle.isEmpty ? '' : ' · $subtitle'}';

    return Material(
      color: isDark ? color.withValues(alpha: 0.16) : Colors.deepOrange.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => showIncompleteOrdersModal(context, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 8 : 12),
          child: Row(
            children: [
              if (compact)
                Icon(
                  Icons.warning_amber_rounded,
                  color: color,
                  size: 18,
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: compact
                    ? Text(
                        'Needs Attention · $countLine',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Needs Attention', style: titleStyle),
                          const SizedBox(height: 2),
                          Text(countLine, style: subtitleStyle),
                        ],
                      ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? color.shade200 : Colors.deepOrange.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
