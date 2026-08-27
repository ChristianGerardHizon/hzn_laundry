import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../domain/product.dart';
import '../../controllers/paginated_products_controller.dart';
import '../../controllers/product_provider.dart';

/// Dialog to convert a product to stock-tracked with starting quantity.
class EnableStockTrackingDialog extends HookConsumerWidget {
  const EnableStockTrackingDialog({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);
    final isSaving = useState(false);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);
        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final updatedProduct = product.copyWith(
        trackStock: true,
        trackByLot: false,
        requireStock: false,
        quantity: _parseNum(values['quantity'] as String?),
        stockThreshold: _parseNum(values['stockThreshold'] as String?),
      );

      final success = await ref
          .read(paginatedProductsControllerProvider.notifier)
          .updateProduct(updatedProduct);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to enable stock tracking. Please try again.'],
          );
        }
        return;
      }

      ref.invalidate(productProvider(product.id));

      if (context.mounted) {
        isSaving.value = false;
        context.pop();
        showSuccessSnackBar(
          context,
          message: 'Stock tracking enabled',
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => FormDialogScaffold(
          title: 'Enable Stock Tracking',
          formKey: formKey,
          dirtyGuard: dirtyGuard,
          isSaving: isSaving.value,
          onSave: handleSave,
          saveLabel: 'Enable',
          maxWidth: DialogConstraints.compactMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Track on-hand quantity for ${product.name}? Enter a starting quantity. You can change threshold and lot settings later in Edit Product.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              NumericInputField(
                name: 'quantity',
                label: 'Starting Quantity',
                required: true,
                enabled: !isSaving.value,
                helperText: 'Current on-hand amount',
              ),
              const SizedBox(height: 16),
              NumericInputField(
                name: 'stockThreshold',
                label: 'Low Stock Threshold',
                enabled: !isSaving.value,
                helperText: 'Optional. Alert when quantity falls below this',
              ),
            ],
          ),
        ),
      ),
    );
  }

  num? _parseNum(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return num.tryParse(text.trim());
  }

  static const _fieldLabels = {
    'quantity': 'Starting Quantity',
    'stockThreshold': 'Low Stock Threshold',
  };
}

/// Shows the enable stock tracking dialog.
void showEnableStockTrackingDialog(BuildContext context, Product product) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => EnableStockTrackingDialog(product: product),
  );
}
