import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/activities.routes.dart';
import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';
import '../utils/activity_log_display.dart';

/// Compact summary of a single activity log with a shortcut to the full
/// [ActivityLogDetailRoute] page.
class ActivityLogSummaryDialog extends StatelessWidget {
  const ActivityLogSummaryDialog({
    super.key,
    required this.log,
    required this.parentContext,
  });

  final ActivityLog log;

  /// Context from the screen that opened the dialog. Used for navigation after
  /// the dialog is popped (the dialog's own context is no longer mounted).
  final BuildContext parentContext;

  static Future<void> show(BuildContext context, ActivityLog log) {
    return showDialog<void>(
      context: context,
      builder: (_) => ActivityLogSummaryDialog(
        log: log,
        parentContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final summary = ActivityLogDisplay.buildShortSummary(log);
    final changeLines = ActivityLogDisplay.buildChangeLines(log);
    final actor = ActivityLogDisplay.actorLabel(log);
    final when =
        log.created != null ? timeFormat.format(log.created!) : 'Unknown time';

    final emptyChangesText = log.action == ActivityAction.create
        ? 'Record was created. No field-level changes to show.'
        : log.action == ActivityAction.delete
            ? 'Record was deleted. No field-level changes to show.'
            : 'No field-level changes recorded.';

    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: log.action.color.withValues(alpha: 0.1),
            child: Icon(log.action.icon, size: 18, color: log.action.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(summary, style: theme.textTheme.titleMedium)),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      log.action.icon,
                      size: 16,
                      color: log.action.color,
                    ),
                    label: Text(log.action.displayName),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(log.collectionDisplayName),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LabeledText(label: 'Who', value: actor),
              const SizedBox(height: 12),
              _LabeledText(label: 'When', value: when),
              const SizedBox(height: 12),
              Text(
                'What changed',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              if (changeLines.isEmpty)
                Text(
                  emptyChangesText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (var i = 0; i < changeLines.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  Text(changeLines[i], style: theme.textTheme.bodyMedium),
                ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            context.pop();
            if (!parentContext.mounted) return;
            ActivityLogDetailRoute(id: log.id).pushScoped(parentContext);
          },
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('View full details'),
        ),
      ],
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
