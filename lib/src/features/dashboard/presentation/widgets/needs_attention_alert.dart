import 'package:flutter/material.dart';

import '../../../../core/packages/theme/feedback_colors.dart';
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
    final colors = FeedbackColors.warning(theme);
    final compact = Breakpoints.isMobile(context);
    final subtitle = [
      if (data.processingCount > 0) '${data.processingCount} processing',
      if (data.missingDataCount > 0) '${data.missingDataCount} missing data',
    ].join(' · ');

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: colors.foreground,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.foreground,
    );
    final countLine = '${data.count} order${data.count == 1 ? '' : 's'}'
        '${subtitle.isEmpty ? '' : ' · $subtitle'}';

    return Material(
      color: colors.background,
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
                  color: colors.icon,
                  size: 18,
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.icon.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: colors.icon,
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
                color: colors.foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
