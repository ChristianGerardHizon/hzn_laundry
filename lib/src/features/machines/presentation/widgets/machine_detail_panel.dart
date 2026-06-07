import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/load_rule_repository.dart';
import '../../domain/load_rule.dart';
import '../../domain/machine.dart';
import '../controllers/load_rules_controller.dart';
import '../controllers/machines_controller.dart';
import 'load_rule_form_dialog.dart';
import 'machine_form_dialog.dart';

/// Detail panel for a machine: shows machine info and manages its load rules.
class MachineDetailPanel extends HookConsumerWidget {
  const MachineDetailPanel({
    super.key,
    required this.machineId,
  });

  final String machineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final machinesAsync = ref.watch(machinesControllerProvider);

    final machine = machinesAsync.value
        ?.cast<Machine?>()
        .firstWhere((m) => m?.id == machineId, orElse: () => null);

    if (machinesAsync.isLoading && machine == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (machine == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Machine not found',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(machine.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => const MachinesRoute().go(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit machine',
            onPressed: () => showMachineFormDialog(context, machine: machine),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MachineInfoCard(machine: machine),
          const SizedBox(height: 24),
          _LoadRulesSection(machine: machine),
        ],
      ),
    );
  }
}

class _MachineInfoCard extends StatelessWidget {
  const _MachineInfoCard({required this.machine});

  final Machine machine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeLabel = machine.size?.displayName ?? 'Unspecified';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_laundry_service,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(machine.name, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Type', value: machine.type.displayName),
                _InfoChip(label: 'Size', value: sizeLabel),
                _InfoChip(
                  label: 'Status',
                  value: machine.isAvailable ? 'Available' : 'Unavailable',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text('$label: $value'),
      labelStyle: theme.textTheme.bodySmall,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}

class _LoadRulesSection extends ConsumerWidget {
  const _LoadRulesSection({required this.machine});

  final Machine machine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rulesAsync = ref.watch(loadRulesControllerProvider(machine.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Load Rules', style: theme.textTheme.titleMedium),
            ),
            if (machine.size != null)
              TextButton.icon(
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Copy to same type/size'),
                onPressed: () => _confirmCopy(context, ref),
              ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add load rule',
              onPressed: () =>
                  showLoadRuleFormDialog(context, machineId: machine.id),
            ),
          ],
        ),
        Text(
          'Weight ranges (kg) that map to a number of loads.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        rulesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $error'),
          ),
          data: (rules) {
            if (rules.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rule_outlined,
                            size: 40, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'No load rules yet',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add a weight tier',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: Column(
                children: [
                  for (var i = 0; i < rules.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _LoadRuleTile(machine: machine, rule: rules[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmCopy(BuildContext context, WidgetRef ref) async {
    final size = machine.size;
    if (size == null) return;

    // Find sibling machines with the same type AND size (excluding this one).
    final allMachines = ref.read(machinesControllerProvider).value ?? [];
    final targets = allMachines
        .where((m) =>
            m.id != machine.id && m.type == machine.type && m.size == size)
        .toList();

    if (targets.isEmpty) {
      showErrorSnackBar(
        context,
        message:
            'No other ${size.displayName.toLowerCase()} ${machine.type.displayName.toLowerCase()} machines to copy to',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Load Rules'),
        content: Text(
          'Copy these load rules to ${targets.length} other '
          '${size.displayName.toLowerCase()} ${machine.type.displayName.toLowerCase()} '
          'machine${targets.length == 1 ? '' : 's'}? '
          'This adds copies and does not remove their existing rules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(loadRuleRepositoryProvider).copyRulesToMachines(
          machine.id,
          targets.map((m) => m.id).toList(),
        );

    if (!context.mounted) return;

    result.fold(
      (failure) => showErrorSnackBar(context, message: 'Copy failed'),
      (count) {
        // Refresh each target's rule list so open panels reflect new rules.
        for (final target in targets) {
          ref.invalidate(loadRulesControllerProvider(target.id));
        }
        showSuccessSnackBar(
          context,
          message: 'Copied $count rule${count == 1 ? '' : 's'} '
              'to ${targets.length} machine${targets.length == 1 ? '' : 's'}',
        );
      },
    );
  }
}

class _LoadRuleTile extends ConsumerWidget {
  const _LoadRuleTile({required this.machine, required this.rule});

  final Machine machine;
  final LoadRule rule;

  String get _rangeLabel {
    final min = (rule.minWeight ?? 0).toStringAsFixed(
      (rule.minWeight ?? 0) % 1 == 0 ? 0 : 1,
    );
    if (rule.maxWeight == null) return '$min kg and up';
    final max = rule.maxWeight!.toStringAsFixed(
      rule.maxWeight! % 1 == 0 ? 0 : 1,
    );
    return '$min – $max kg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '${rule.loadCount}',
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
      title: Text(_rangeLabel),
      subtitle: Text('${rule.loadCount} load${rule.loadCount == 1 ? '' : 's'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => showLoadRuleFormDialog(
              context,
              machineId: machine.id,
              rule: rule,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Load Rule'),
        content: Text('Delete the rule for $_rangeLabel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(loadRulesControllerProvider(machine.id).notifier)
        .deleteRule(rule.id);

    if (!context.mounted) return;
    if (success) {
      showSuccessSnackBar(context, message: 'Load rule deleted');
    } else {
      showErrorSnackBar(context, message: 'Failed to delete load rule');
    }
  }
}
