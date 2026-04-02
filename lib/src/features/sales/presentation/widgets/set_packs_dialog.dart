import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

/// Dialog for setting the number of laundry bags/packs for an order.
///
/// Returns the selected pack count as [int], or `null` if cancelled.
class SetPacksDialog extends HookWidget {
  const SetPacksDialog({super.key});

  static const _presetValues = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = useState<int?>(null);

    return AlertDialog(
      title: const Text('Set Number of Packs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many laundry bags were used for this order?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetValues.map((value) {
              final isSelected = selected.value == value;
              return ChoiceChip(
                label: Text('$value'),
                selected: isSelected,
                onSelected: (_) => selected.value = value,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                selectedColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => context.pop(0),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed:
              selected.value != null ? () => context.pop(selected.value) : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Shows the set packs dialog.
///
/// Returns the selected pack count, `0` if skipped, or `null` if cancelled.
Future<int?> showSetPacksDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const SetPacksDialog(),
  );
}
