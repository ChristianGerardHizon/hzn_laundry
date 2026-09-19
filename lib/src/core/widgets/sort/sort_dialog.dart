import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../foundation/sort_config.dart';
import '../../i18n/strings.g.dart';
import '../dialog/dialog_constraints.dart';
import '../dialog_close_handler.dart';

/// A reusable dialog for selecting sort field and direction.
class SortDialog extends HookWidget {
  const SortDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.currentSort,
    required this.onSortChanged,
    required this.defaultSort,
  });

  /// Dialog title.
  final String title;

  /// List of sortable fields with (key, label) pairs.
  final List<SortableField> fields;

  /// Current sort configuration.
  final SortConfig currentSort;

  /// Callback when sort configuration changes.
  final ValueChanged<SortConfig> onSortChanged;

  /// Default sort configuration for reset.
  final SortConfig defaultSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Local state for the dialog
    final selectedField = useState(currentSort.field);
    final isDescending = useState(currentSort.descending);

    void applySort() {
      onSortChanged(SortConfig(
        field: selectedField.value,
        descending: isDescending.value,
      ));
      context.pop();
    }

    void resetSort() {
      selectedField.value = defaultSort.field;
      isDescending.value = defaultSort.descending;
    }

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        shrinkWrap: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.sort.direction,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: true,
                          label: Text(t.sort.descending),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text(t.sort.ascending),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {isDescending.value},
                      onSelectionChanged: (selection) {
                        isDescending.value = selection.first;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.sort.sortBy,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: selectedField.value,
                      onChanged: (value) {
                        if (value != null) {
                          selectedField.value = value;
                        }
                      },
                      child: Column(
                        children: fields.map((field) {
                          final isSelected = selectedField.value == field.key;
                          return RadioListTile<String>(
                            value: field.key,
                            title: Text(field.label),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            selected: isSelected,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: resetSort,
                      child: Text(t.common.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: applySort,
                      child: Text(t.common.done),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the sort dialog.
void showSortDialog({
  required BuildContext context,
  required String title,
  required List<SortableField> fields,
  required SortConfig currentSort,
  required ValueChanged<SortConfig> onSortChanged,
  required SortConfig defaultSort,
}) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    shrinkWrap: true,
    builder: (context) => SortDialog(
      title: title,
      fields: fields,
      currentSort: currentSort,
      onSortChanged: onSortChanged,
      defaultSort: defaultSort,
    ),
  );
}
