import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../controllers/sale_search_controller.dart';

/// Dialog for selecting sale search fields and payment filters.
class SaleSearchFieldsDialog extends ConsumerWidget {
  const SaleSearchFieldsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final selectedFields = ref.watch(saleSearchFieldsProvider);
    final paymentFilters = ref.watch(salePaymentFiltersControllerProvider);

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
                      t.fields.searchFields,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () {
                        ref.read(saleSearchFieldsProvider.notifier).reset();
                        ref
                            .read(salePaymentFiltersControllerProvider.notifier)
                            .reset();
                      },
                      child: Text(t.common.reset),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: Text(t.common.done),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.fields.searchFieldsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...saleSearchableFields.map((field) {
                      final isSelected = selectedFields.contains(field);
                      final isLastSelected =
                          isSelected && selectedFields.length == 1;

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: isLastSelected
                            ? null
                            : (_) => ref
                                .read(saleSearchFieldsProvider.notifier)
                                .toggleField(field),
                        title: Text(_getFieldLabel(field, t)),
                        subtitle: isLastSelected
                            ? Text(
                                t.fields.atLeastOneRequired,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    const SizedBox(height: 16),
                    Text(
                      t.fields.paymentFilters,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CheckboxListTile(
                      value: paymentFilters.paid,
                      onChanged: (_) => ref
                          .read(salePaymentFiltersControllerProvider.notifier)
                          .togglePaid(),
                      title: Text(t.fields.paid),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: paymentFilters.unpaid,
                      onChanged: (_) => ref
                          .read(salePaymentFiltersControllerProvider.notifier)
                          .toggleUnpaid(),
                      title: Text(t.fields.unpaid),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: paymentFilters.cash,
                      onChanged: (_) => ref
                          .read(salePaymentFiltersControllerProvider.notifier)
                          .toggleCash(),
                      title: Text(t.fields.cash),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: paymentFilters.gcashBank,
                      onChanged: (_) => ref
                          .read(salePaymentFiltersControllerProvider.notifier)
                          .toggleGcashBank(),
                      title: Text(t.fields.gcashBank),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldLabel(String field, Translations t) {
    switch (field) {
      case 'receiptNumber':
        return t.fields.receiptNumber;
      case 'customerName':
        return t.fields.customerName;
      case 'paymentRef':
        return t.fields.paymentRef;
      case 'notes':
        return t.fields.notes;
      default:
        return field;
    }
  }
}

/// Shows the sale search fields selection dialog.
void showSaleSearchFieldsDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    shrinkWrap: true,
    builder: (context) => const SaleSearchFieldsDialog(),
  );
}
