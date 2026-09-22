import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/auth.routes.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/organization_platform_stats_controller.dart';
import '../controllers/organization_selection_gate.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';
import '../widgets/super_admin_nav_panel.dart';

const _kInk = Color(0xFF0B0B0B);

/// Adaptive shell for the platform Super Admin hub.
///
/// - Tablet+: persistent [SuperAdminNavPanel] + routed content
/// - Mobile: drawer with the same sections + menu button
class SuperAdminShell extends HookConsumerWidget {
  const SuperAdminShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCreating = useState(false);
    final scaffoldKey = useMemoized(GlobalKey<ScaffoldState>.new);
    final location = GoRouterState.of(context).uri.path;
    final section = _sectionForPath(location);
    final isTablet = Breakpoints.isTabletOrLarger(context);

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
          ref
              .read(organizationPlatformStatsControllerProvider.notifier)
              .refresh();
          const SplashRoute().go(context);
        }
      } finally {
        if (context.mounted) isCreating.value = false;
      }
    }

    void goToSection(SuperAdminSection next) {
      switch (next) {
        case SuperAdminSection.dashboard:
          const SuperAdminRoute().go(context);
        case SuperAdminSection.packages:
          const SuperAdminPackagesRoute().go(context);
        case SuperAdminSection.payments:
          const SuperAdminPaymentsRoute().go(context);
        case SuperAdminSection.billing:
          const SuperAdminBillingRoute().go(context);
      }
      if (!isTablet) {
        scaffoldKey.currentState?.closeDrawer();
      }
    }

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          if (!isTablet)
            IconButton(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
              color: kSuperAdminBrandTeal,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          TextButton.icon(
            onPressed: isCreating.value
                ? null
                : () => const SelectOrganizationRoute().go(context),
            style: TextButton.styleFrom(
              foregroundColor: kSuperAdminBrandTeal,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.arrow_back),
            label: Text(t.organizations.back),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: isCreating.value ? null : openCreate,
            style: FilledButton.styleFrom(
              backgroundColor: kSuperAdminBrandTeal,
              foregroundColor: _kInk,
              minimumSize: const Size(44, 44),
            ),
            icon: isCreating.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kInk,
                    ),
                  )
                : const Icon(Icons.add_business_outlined),
            label: Text(t.organizations.create),
          ),
        ],
      ),
    );

    final titleBlock = Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        children: [
          Assets.icons.appIconTransparent.image(
            width: 48,
            height: 48,
          ),
          const SizedBox(height: 12),
          Text(
            t.organizations.superAdminTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            t.organizations.superAdminSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                  height: 1.35,
                ),
          ),
        ],
      ),
    );

    final navPanel = SuperAdminNavPanel(
      currentSection: section,
      onSectionChanged: goToSection,
    );
    final drawerNav = SuperAdminNavPanel(
      currentSection: section,
      onSectionChanged: goToSection,
      expanded: true,
    );

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: _kInk,
            drawer: isTablet
                ? null
                : Drawer(
                    backgroundColor: kSuperAdminSurface,
                    child: SafeArea(child: drawerNav),
                  ),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isTablet) ...[
                    navPanel,
                    const VerticalDivider(
                      width: 1,
                      color: kSuperAdminSurfaceBorder,
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        titleBlock,
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static SuperAdminSection _sectionForPath(String path) {
    if (path.endsWith('/packages') || path.contains('/packages/')) {
      return SuperAdminSection.packages;
    }
    if (path.endsWith('/payments') || path.contains('/payments/')) {
      return SuperAdminSection.payments;
    }
    if (path.endsWith('/billing') || path.contains('/billing/')) {
      return SuperAdminSection.billing;
    }
    return SuperAdminSection.dashboard;
  }
}
