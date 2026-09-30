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
import '../widgets/super_admin_mobile_bottom_nav.dart';
import '../widgets/super_admin_nav_panel.dart';

/// Adaptive shell for the platform Super Admin hub.
///
/// - Tablet+: persistent [SuperAdminNavPanel] + routed content
/// - Mobile: bottom nav (3 sections + More) + drawer for full menu
class SuperAdminShell extends HookConsumerWidget {
  const SuperAdminShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isCreating = useState(false);
    final scaffoldKey = useMemoized(GlobalKey<ScaffoldState>.new);
    final location = GoRouterState.of(context).uri.path;
    final section = _sectionForPath(location);
    final isTablet = Breakpoints.isMultiColumnOrLarger(context);

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

    const spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: kSuperAdminInk,
      ),
    );

    final topBar = Padding(
      padding: EdgeInsets.fromLTRB(isTablet ? 24 : 8, 8, isTablet ? 24 : 12, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: t.organizations.back,
            onPressed: isCreating.value
                ? null
                : () => const SelectOrganizationRoute().go(context),
            style: IconButton.styleFrom(
              foregroundColor: kSuperAdminBrandTeal,
              minimumSize: const Size(kSuperAdminMinTap, kSuperAdminMinTap),
            ),
            icon: const Icon(Icons.arrow_back),
          ),
          if (!isTablet) ...[
            Assets.icons.appIconTransparent.image(width: 32, height: 32),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.organizations.superAdminTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
                if (isTablet)
                  Text(
                    t.organizations.superAdminSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kSuperAdminMuted,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isTablet)
            FilledButton.icon(
              onPressed: isCreating.value ? null : openCreate,
              style: FilledButton.styleFrom(
                backgroundColor: kSuperAdminBrandTeal,
                foregroundColor: kSuperAdminInk,
                minimumSize: const Size(kSuperAdminMinTap, kSuperAdminMinTap),
              ),
              icon: isCreating.value
                  ? spinner
                  : const Icon(Icons.add_business_outlined),
              label: Text(t.organizations.create),
            )
          else
            IconButton.filled(
              tooltip: t.organizations.create,
              onPressed: isCreating.value ? null : openCreate,
              style: IconButton.styleFrom(
                backgroundColor: kSuperAdminBrandTeal,
                foregroundColor: kSuperAdminInk,
                minimumSize: const Size(kSuperAdminMinTap, kSuperAdminMinTap),
              ),
              icon: isCreating.value
                  ? spinner
                  : const Icon(Icons.add_business_outlined),
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
            backgroundColor: kSuperAdminInk,
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
                        topBar,
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: isTablet
                ? null
                : SuperAdminMobileBottomNav(
                    currentSection: section,
                    onSectionSelected: goToSection,
                    onMoreTap: () => scaffoldKey.currentState?.openDrawer(),
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
