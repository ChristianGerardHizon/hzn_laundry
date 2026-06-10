import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/customer.dart';
import '../controllers/customers_controller.dart';

/// Shows a dialog form for creating or editing a customer.
///
/// Uses the root navigator so the dialog renders above all routes.
/// If [onSaved] is provided, it will be called with the saved customer data
/// after a successful create or update.
void showCustomerFormDialog(
  BuildContext context, {
  Customer? customer,
  String? initialName,
  ValueChanged<Customer>? onSaved,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => CustomerFormDialog(
      customer: customer,
      initialName: initialName,
      onSaved: onSaved,
    ),
  );
}

/// @deprecated Use [showCustomerFormDialog] instead.
Future<bool?> showCustomerFormSheet(
  BuildContext context, {
  Customer? customer,
}) {
  showCustomerFormDialog(context, customer: customer);
  return Future.value(null);
}

/// Dialog for creating or editing a customer.
class CustomerFormDialog extends HookConsumerWidget {
  const CustomerFormDialog({
    super.key,
    this.customer,
    this.initialName,
    this.onSaved,
  });

  final Customer? customer;
  final String? initialName;
  final ValueChanged<Customer>? onSaved;

  bool get isEditing => customer != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': customer!.name,
              'phone': customer!.phone,
              'email': customer!.email,
              'address': customer!.address,
              'notes': customer!.notes,
            }
          : initialName != null
              ? {'name': initialName}
              : null,
    );

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

      final customerData = Customer(
        id: customer?.id ?? '',
        name: (values['name'] as String).trim(),
        phone: values['phone'] as String?,
        email: values['email'] as String?,
        address: values['address'] as String?,
        notes: values['notes'] as String?,
      );

      final controller = ref.read(customersControllerProvider.notifier);

      Customer? savedCustomer;
      if (isEditing) {
        final success = await controller.updateCustomer(customerData);
        if (success) savedCustomer = customerData;
      } else {
        savedCustomer = await controller.createCustomer(customerData);
      }

      if (savedCustomer == null) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save customer. Please try again.'],
          );
        }
        return;
      }

      onSaved?.call(savedCustomer);

      if (context.mounted) {
        isSaving.value = false;
        context.pop();
        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Customer updated successfully'
              : 'Customer created successfully',
        );
      }
    }

    return DialogCloseHandler(
      onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
        child: ConstrainedDialogContent(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              if (await dirtyGuard.confirmDiscard(context)) {
                                if (context.mounted) context.pop();
                              }
                            },
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Customer' : 'New Customer',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                if (await dirtyGuard
                                    .confirmDiscard(context)) {
                                  if (context.mounted) context.pop();
                                }
                              },
                        child: Text(t.common.cancel),
                      ),
                    ),
                    FilledButton(
                      onPressed: isSaving.value ? null : handleSave,
                      child: isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.save),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Form
              Expanded(
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: customer?.name ?? initialName,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'phone',
                          initialValue: customer?.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          enabled: !isSaving.value,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'email',
                          initialValue: customer?.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            helperText:
                                'Used to send order history link',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: !isSaving.value,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.email(
                              errorText: 'Invalid email',
                              checkNullOrEmpty: false,
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'address',
                          initialValue: customer?.address,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          enabled: !isSaving.value,
                          maxLines: 2,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'notes',
                          initialValue: customer?.notes,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notes),
                          ),
                          enabled: !isSaving.value,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'phone': 'Phone',
    'email': 'Email',
    'address': 'Address',
    'notes': 'Notes',
  };
}
