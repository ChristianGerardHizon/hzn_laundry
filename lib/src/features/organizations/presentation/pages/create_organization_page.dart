import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/organizations.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/organization_repository.dart';
import '../controllers/current_organization_controller.dart';

class CreateOrganizationPage extends HookConsumerWidget {
  const CreateOrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final t = Translations.of(context);

    Future<void> handleSave() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      final values = formKey.currentState!.value;
      isSaving.value = true;
      final result = await ref.read(organizationRepositoryProvider).create(
            name: (values['name'] as String).trim(),
            contactNumber: (values['contactNumber'] as String?)?.trim(),
            address: (values['address'] as String?)?.trim(),
          );
      isSaving.value = false;
      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.messageString);
          }
        },
        (org) async {
          await ref
              .read(currentOrganizationControllerProvider.notifier)
              .selectOrganization(org.id);
          if (context.mounted) {
            OrganizationSetupRoute(id: org.id).go(context);
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.organizations.create)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FormBuilder(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: '${t.fields.name} *',
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'contactNumber',
                    decoration: InputDecoration(
                      labelText: t.fields.contactNumber,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'address',
                    decoration: InputDecoration(
                      labelText: t.fields.address,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isSaving.value ? null : handleSave,
                    child: isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.organizations.create),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
