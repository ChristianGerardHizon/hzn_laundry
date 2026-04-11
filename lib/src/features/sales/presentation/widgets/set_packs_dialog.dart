import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

/// Dialog for setting the number of laundry bags/packs for an order.
///
/// Returns the selected pack count as [int], or `null` if cancelled.
class SetPacksDialog extends HookWidget {
  const SetPacksDialog({super.key, this.initialPacks});

  final int? initialPacks;

  static const _presetValues = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = useState<int?>(initialPacks);
    final isCustomMode = useState(false);
    final customController = useTextEditingController();

    // If initial value is set and not in presets, start in custom mode
    useEffect(() {
      if (initialPacks != null && !_presetValues.contains(initialPacks)) {
        isCustomMode.value = true;
        customController.text = '$initialPacks';
      }
      return null;
    }, []);

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
          if (!isCustomMode.value) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._presetValues.map((value) {
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
                }),
                ActionChip(
                  label: const Text('Custom'),
                  avatar: const Icon(Icons.edit, size: 16),
                  onPressed: () {
                    isCustomMode.value = true;
                    selected.value = null;
                  },
                ),
              ],
            ),
          ] else ...[
            TextField(
              controller: customController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Number of packs',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.grid_view, size: 20),
                  tooltip: 'Show presets',
                  onPressed: () {
                    isCustomMode.value = false;
                    selected.value = null;
                  },
                ),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                selected.value = (parsed != null && parsed > 0) ? parsed : null;
              },
            ),
          ],
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
Future<int?> showSetPacksDialog(
  BuildContext context, {
  int? initialPacks,
}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SetPacksDialog(initialPacks: initialPacks),
  );
}
