import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../domain/organization.dart';
import '../../controllers/current_organization_controller.dart';

class OrganizationOverviewTab extends HookConsumerWidget {
  const OrganizationOverviewTab({
    super.key,
    required this.organization,
    required this.onSaved,
  });

  final Organization organization;
  final Future<void> Function() onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final membership = ref
        .watch(currentOrganizationControllerProvider.notifier)
        .membershipFor(organization.id);
    final canManage = membership?.canManageMembers ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t.organizations.details,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        FormBuilder(
          key: formKey,
          initialValue: {
            'name': organization.name,
            'contactNumber': organization.contactNumber ?? '',
            'address': organization.address ?? '',
          },
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.name),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'contactNumber',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.contactNumber),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'address',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.address),
                maxLines: 2,
              ),
              if (canManage) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.saveAndValidate() ?? false)) {
                        return;
                      }
                      final values = formKey.currentState!.value;
                      final result = await ref
                          .read(organizationRepositoryProvider)
                          .update(
                            organization.id,
                            name: values['name'] as String,
                            contactNumber:
                                values['contactNumber'] as String?,
                            address: values['address'] as String?,
                          );
                      if (!context.mounted) return;
                      result.fold(
                        (f) => showErrorSnackBar(
                          context,
                          message: f.messageString,
                        ),
                        (_) async {
                          showSuccessSnackBar(
                            context,
                            message: t.organizations.saveSuccess,
                          );
                          await ref
                              .read(
                                currentOrganizationControllerProvider.notifier,
                              )
                              .refresh();
                          await onSaved();
                        },
                      );
                    },
                    child: Text(t.organizations.saveDetails),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
