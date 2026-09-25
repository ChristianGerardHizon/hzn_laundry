import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';
import '../controllers/activity_log_provider.dart';
import '../utils/activity_log_display.dart';

/// Full detail view for a single activity log entry.
class ActivityLogDetailPage extends HookConsumerWidget {
  const ActivityLogDetailPage({super.key, required this.activityLogId});

  final String activityLogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(activityLogProvider(activityLogId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(activityLogProvider(activityLogId)),
          ),
        ],
      ),
      body: logAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load activity'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(activityLogProvider(activityLogId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (log) {
          if (log == null) {
            return const Center(child: Text('Activity not found'));
          }
          return _ActivityLogDetailBody(log: log);
        },
      ),
    );
  }
}

class _ActivityLogDetailBody extends StatelessWidget {
  const _ActivityLogDetailBody({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final summary = ActivityLogDisplay.buildShortSummary(log);
    final changeLines = ActivityLogDisplay.buildChangeLines(log);
    final canOpen = ActivityLogDisplay.canOpenRecord(log);
    final actor = ActivityLogDisplay.actorLabel(log);
    final when =
        log.created != null ? timeFormat.format(log.created!) : 'Unknown time';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: log.action.color.withValues(alpha: 0.1),
                    child: Icon(
                      log.action.icon,
                      color: log.action.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionCard(
                title: 'Who',
                child: Text(actor, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'When',
                child: Text(when, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'What was affected',
                child: Text(
                  log.collectionDisplayName,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'What changed',
                child: changeLines.isEmpty
                    ? Text(
                        log.action == ActivityAction.create
                            ? 'Record was created. No field-level changes to show.'
                            : log.action == ActivityAction.delete
                                ? 'Record was deleted. No field-level changes to show.'
                                : 'No field-level changes recorded.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < changeLines.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            Text(
                              changeLines[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
        if (canOpen)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ActivityLogDisplay.openRecord(context, log),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(ActivityLogDisplay.openRecordLabel(log)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
