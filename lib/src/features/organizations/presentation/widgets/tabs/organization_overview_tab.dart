import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/utils/file_validation.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../../core/widgets/organization_letter_mark.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final isUploadingLogo = useState(false);
    final membership = ref
        .watch(currentOrganizationControllerProvider.notifier)
        .membershipFor(organization.id);
    final canManage = membership?.canManageMembers ?? false;
    final isWide = Breakpoints.isMultiColumnOrLarger(context);

    Future<void> pickAndUploadLogo() async {
      if (!canManage || isUploadingLogo.value) return;

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final validationError = FileValidation.validate(image.name, bytes.length);
      if (validationError != null) {
        if (!context.mounted) return;
        showErrorSnackBar(context, message: validationError);
        return;
      }

      isUploadingLogo.value = true;
      try {
        final file = http.MultipartFile.fromBytes(
          'logo',
          bytes,
          filename: image.name,
        );
        final result = await ref
            .read(organizationRepositoryProvider)
            .updateLogo(organization.id, file);
        if (!context.mounted) return;
        await result.fold(
          (f) async {
            showErrorSnackBar(context, message: f.messageString);
          },
          (_) async {
            showSuccessSnackBar(context, message: t.organizations.logoUpdated);
            await ref
                .read(currentOrganizationControllerProvider.notifier)
                .refresh();
            await onSaved();
          },
        );
      } catch (_) {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: t.organizations.logoUploadFailed,
          );
        }
      } finally {
        isUploadingLogo.value = false;
      }
    }

    Future<void> removeLogo() async {
      if (!canManage || isUploadingLogo.value || !organization.hasLogo) return;

      isUploadingLogo.value = true;
      try {
        final result = await ref
            .read(organizationRepositoryProvider)
            .clearLogo(organization.id);
        if (!context.mounted) return;
        await result.fold(
          (f) async {
            showErrorSnackBar(context, message: f.messageString);
          },
          (_) async {
            showSuccessSnackBar(context, message: t.organizations.logoRemoved);
            await ref
                .read(currentOrganizationControllerProvider.notifier)
                .refresh();
            await onSaved();
          },
        );
      } finally {
        isUploadingLogo.value = false;
      }
    }

    Future<void> saveDetails() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      if (isSaving.value) return;

      isSaving.value = true;
      try {
        final values = formKey.currentState!.value;
        final result = await ref.read(organizationRepositoryProvider).update(
              organization.id,
              name: values['name'] as String,
              contactNumber: values['contactNumber'] as String?,
              address: values['address'] as String?,
            );
        if (!context.mounted) return;
        await result.fold(
          (f) async {
            showErrorSnackBar(context, message: f.messageString);
          },
          (_) async {
            showSuccessSnackBar(
              context,
              message: t.organizations.saveSuccess,
            );
            await ref
                .read(currentOrganizationControllerProvider.notifier)
                .refresh();
            await onSaved();
          },
        );
      } finally {
        isSaving.value = false;
      }
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.organizations.branding,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Semantics(
                      button: canManage,
                      label: t.organizations.changeLogo,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: canManage ? pickAndUploadLogo : null,
                              customBorder: const CircleBorder(),
                              child: OrganizationLetterMark(
                                name: organization.name,
                                logoUrl: organization.logoUrl,
                                size: 88,
                              ),
                            ),
                          ),
                          if (canManage)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: colors.primary,
                                shape: const CircleBorder(),
                                elevation: 1,
                                child: InkWell(
                                  onTap: isUploadingLogo.value
                                      ? null
                                      : pickAndUploadLogo,
                                  customBorder: const CircleBorder(),
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: isUploadingLogo.value
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colors.onPrimary,
                                              ),
                                            )
                                          : Icon(
                                              Icons.camera_alt_rounded,
                                              size: 18,
                                              color: colors.onPrimary,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            organization.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (organization.slug.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '/${organization.slug}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (canManage) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: isUploadingLogo.value
                                      ? null
                                      : pickAndUploadLogo,
                                  icon: const Icon(Icons.upload_rounded),
                                  label: Text(t.organizations.changeLogo),
                                ),
                                if (organization.hasLogo)
                                  TextButton.icon(
                                    onPressed: isUploadingLogo.value
                                        ? null
                                        : removeLogo,
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: colors.error,
                                    ),
                                    label: Text(
                                      t.organizations.removeLogo,
                                      style: TextStyle(color: colors.error),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FormBuilder(
              key: formKey,
              initialValue: {
                'name': organization.name,
                'contactNumber': organization.contactNumber ?? '',
                'address': organization.address ?? '',
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.organizations.details,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'name',
                    enabled: canManage,
                    decoration: InputDecoration(
                      labelText: t.fields.name,
                      border: const OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'contactNumber',
                    enabled: canManage,
                    decoration: InputDecoration(
                      labelText: t.fields.contactNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'address',
                    enabled: canManage,
                    decoration: InputDecoration(
                      labelText: t.fields.address,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 2,
                  ),
                  if (canManage) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: isSaving.value ? null : saveDetails,
                        icon: isSaving.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          isSaving.value
                              ? t.organizations.saving
                              : t.organizations.saveDetails,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 16,
            vertical: 16,
          ),
          children: [content],
        ),
      ),
    );
  }
}
