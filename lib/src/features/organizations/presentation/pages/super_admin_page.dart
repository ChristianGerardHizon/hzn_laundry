import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/auth.routes.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organization_selection_gate.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);

/// Out-of-scope hub for `system.admin` users (create org, etc.).
class SuperAdminPage extends HookConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCreating = useState(false);
    ref.watch(currentOrganizationControllerProvider);

    Future<void> openCreate() async {
      if (isCreating.value) return;
      isCreating.value = true;
      try {
        final created = await showCreateOrganizationSetupDialog(context);
        if (created == true && context.mounted) {
          ref.read(organizationSelectionConfirmedProvider.notifier).confirm();
          showSuccessSnackBar(
            context,
            message: t.organizations.onboardingComplete,
            useRootMessenger: false,
          );
          const SplashRoute().go(context);
        }
      } finally {
        if (context.mounted) isCreating.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _kInk,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: isCreating.value
                                ? null
                                : () =>
                                    const SelectOrganizationRoute().go(context),
                            style: TextButton.styleFrom(
                              foregroundColor: _kBrandTeal,
                              minimumSize: const Size(44, 44),
                            ),
                            icon: const Icon(Icons.arrow_back),
                            label: Text(t.organizations.back),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Assets.icons.appIconTransparent.image(
                            width: 56,
                            height: 56,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.organizations.superAdminTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.organizations.superAdminSubtitle,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.62),
                                    height: 1.35,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _kSurface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kSurfaceBorder),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isCreating.value ? null : openCreate,
                              borderRadius: BorderRadius.circular(16),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 64),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _kBrandTeal.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: isCreating.value
                                            ? const Padding(
                                                padding: EdgeInsets.all(10),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  color: _kBrandTeal,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.add_business_outlined,
                                                color: _kBrandTeal,
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          t.organizations.create,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.45),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
