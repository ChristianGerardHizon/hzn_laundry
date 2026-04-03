import 'package:flutter/material.dart';

/// A search field descriptor for report tables.
class ReportSearchField {
  const ReportSearchField({required this.key, required this.label});

  final String key;
  final String label;
}

/// A search bar with a filter button that opens a modal to select which
/// fields to include in the search.
class ReportSearchBar extends StatelessWidget {
  const ReportSearchBar({
    super.key,
    required this.fields,
    required this.selectedKeys,
    required this.controller,
    required this.onSelectedKeysChanged,
  });

  final List<ReportSearchField> fields;
  final Set<String> selectedKeys;
  final TextEditingController controller;
  final ValueChanged<Set<String>> onSelectedKeysChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = selectedKeys.length;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => controller.clear(),
                ),
              IconButton(
                icon: Badge(
                  isLabelVisible: activeCount < fields.length,
                  label: Text('$activeCount'),
                  child: const Icon(Icons.tune, size: 20),
                ),
                tooltip: 'Search fields',
                onPressed: () => _showFieldsDialog(context),
              ),
            ],
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  void _showFieldsDialog(BuildContext context) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final working = Set<String>.from(selectedKeys);

    showDialog<void>(
      context: rootContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Search in'),
              titleTextStyle: Theme.of(context).textTheme.titleSmall,
              contentPadding: const EdgeInsets.only(top: 8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields.map((f) {
                  final checked = working.contains(f.key);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(f.label),
                    dense: true,
                    onChanged: (v) {
                      setDialogState(() {
                        if (v == true) {
                          working.add(f.key);
                        } else if (working.length > 1) {
                          // Keep at least one field selected.
                          working.remove(f.key);
                        }
                      });
                      onSelectedKeysChanged(Set.from(working));
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
