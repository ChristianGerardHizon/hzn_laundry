import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../controllers/billing_settings_controller.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);
const _kMuted = Color(0xFF9CA3AF);

/// Super Admin tab: platform billing settings (QRPH, grace, instructions).
class BillingSettingsTab extends HookConsumerWidget {
  const BillingSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final settingsAsync = ref.watch(billingSettingsControllerProvider);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final qrphBytes = useState<Uint8List?>(null);
    final qrphName = useState<String?>(null);

    return settingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: _kBrandTeal),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState.fromError(
            e,
            onRetry: () =>
                ref.read(billingSettingsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
      data: (settings) {
        Future<void> pickQrph() async {
          final picker = ImagePicker();
          final file = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 90,
          );
          if (file == null) return;
          qrphBytes.value = await file.readAsBytes();
          qrphName.value = file.name;
        }

        Future<void> save() async {
          if (!formKey.currentState!.saveAndValidate()) return;
          if (isSaving.value) return;
          isSaving.value = true;
          try {
            final values = formKey.currentState!.value;
            http.MultipartFile? qrphFile;
            final bytes = qrphBytes.value;
            if (bytes != null) {
              qrphFile = http.MultipartFile.fromBytes(
                'qrphImage',
                bytes,
                filename: qrphName.value ?? 'qrph.jpg',
              );
            }

            final ok = await ref
                .read(billingSettingsControllerProvider.notifier)
                .updateSettings(
                  payeeName: (values['payeeName'] as String?)?.trim(),
                  instructions: (values['instructions'] as String?)?.trim(),
                  defaultGraceDays:
                      int.tryParse(values['defaultGraceDays'].toString()),
                  qrphImage: qrphFile,
                );
            if (!context.mounted) return;
            if (ok) {
              qrphBytes.value = null;
              qrphName.value = null;
              showSuccessSnackBar(
                context,
                message: t.subscriptions.billingSaved,
                useRootMessenger: false,
              );
            } else {
              showErrorSnackBar(
                context,
                message: t.subscriptions.billingSaveFailed,
                useRootMessenger: false,
              );
            }
          } finally {
            if (context.mounted) isSaving.value = false;
          }
        }

        return RefreshIndicator(
          color: _kBrandTeal,
          onRefresh: () =>
              ref.read(billingSettingsControllerProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              FormBuilder(
                key: formKey,
                initialValue: {
                  'payeeName': settings.payeeName,
                  'instructions': settings.instructions,
                  'defaultGraceDays': settings.defaultGraceDays.toString(),
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormBuilderTextField(
                      name: 'payeeName',
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        label: t.subscriptions.payeeName,
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 14),
                    FormBuilderTextField(
                      name: 'instructions',
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        label: t.subscriptions.instructions,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 14),
                    FormBuilderTextField(
                      name: 'defaultGraceDays',
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        label: t.subscriptions.defaultGraceDays,
                      ),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                        FormBuilderValidators.min(0),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.subscriptions.qrphImage,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (qrphBytes.value != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          qrphBytes.value!,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (settings.qrphImageUrl != null &&
                        settings.qrphImageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          settings.qrphImageUrl!,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 120,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: _kMuted,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kSurfaceBorder),
                        ),
                        child: Text(
                          t.subscriptions.qrphImage,
                          style: const TextStyle(color: _kMuted),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isSaving.value ? null : pickQrph,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kBrandTeal,
                        side: const BorderSide(color: _kBrandTeal),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(
                        qrphName.value ?? t.subscriptions.uploadQrph,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isSaving.value ? null : save,
                      style: FilledButton.styleFrom(
                        backgroundColor: _kBrandTeal,
                        foregroundColor: _kInk,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kInk,
                              ),
                            )
                          : Text(t.common.save),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _fieldDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _kMuted),
      filled: true,
      fillColor: _kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kSurfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kSurfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBrandTeal),
      ),
    );
  }
}
