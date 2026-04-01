import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/service_category_repository.dart';
import '../../domain/service_category.dart';
import '../controllers/service_categories_provider.dart';

/// Shows a dialog form for creating or editing a service category.
///
/// Returns `true` if the category was saved successfully.
Future<bool?> showServiceCategoryFormSheet(
  BuildContext context, {
  ServiceCategory? category,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _ServiceCategoryFormDialog(category: category),
  );
}

class _ServiceCategoryFormDialog extends HookConsumerWidget {
  const _ServiceCategoryFormDialog({this.category});

  final ServiceCategory? category;

  bool get isEditing => category != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;
      final repo = ref.read(serviceCategoryRepositoryProvider);

      final categoryData = ServiceCategory(
        id: category?.id ?? '',
        name: values['name'] as String,
      );

      final result = isEditing
          ? await repo.update(categoryData)
          : await repo.create(categoryData);

      isSaving.value = false;

      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: isEditing
                  ? 'Failed to update category'
                  : 'Failed to create category',
              useRootMessenger: false,
            );
          }
        },
        (_) {
          ref.invalidate(serviceCategoriesProvider);
          if (context.mounted) {
            showSuccessSnackBar(
              context,
              message: isEditing ? 'Category updated' : 'Category created',
              useRootMessenger: false,
            );
            Navigator.of(context).pop(true);
          }
        },
      );
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'New Category'),
          content: FormBuilder(
            key: formKey,
            child: FormBuilderTextField(
              name: 'name',
              initialValue: category?.name,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(),
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : handleSave,
              child: isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
