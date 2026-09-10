import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/auth_repository.dart';

/// Forgot password page — sends a PocketBase reset email.
class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSending = useState(false);
    final sentTo = useState<String?>(null);

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      final email =
          (formKey.currentState!.value['email'] as String).trim().toLowerCase();
      isSending.value = true;
      final result =
          await ref.read(authRepositoryProvider).requestPasswordReset(email);
      isSending.value = false;
      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.messageString);
          }
        },
        (_) => sentTo.value = email,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.auth.forgotPasswordTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: sentTo.value != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.auth.checkEmail,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.auth.resetLinkSent(email: sentTo.value!),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        child: Text(t.auth.backToLogin),
                      ),
                    ],
                  )
                : FormBuilder(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.lock_reset_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t.auth.forgotPasswordTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.auth.forgotPasswordSubtitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FormBuilderTextField(
                          name: 'email',
                          enabled: !isSending.value,
                          decoration: InputDecoration(
                            labelText: t.fields.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                          onSubmitted:
                              isSending.value ? null : (_) => handleSubmit(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: isSending.value ? null : handleSubmit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: isSending.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(t.auth.sendResetLink),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          child: Text(t.auth.backToLogin),
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
