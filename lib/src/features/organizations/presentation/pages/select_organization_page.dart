import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/pending_redirect_provider.dart';
import '../../../../core/routing/routes/dashboard.routes.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/widgets/nav_permissions.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organization_selection_gate.dart';

/// HZN brand teal sampled from the logo mark (matches login).
const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);

/// Post-login screen: pick which organization to enter.
class SelectOrganizationPage extends HookConsumerWidget {
  const SelectOrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final memberships =
        ref.watch(currentOrganizationControllerProvider.notifier).memberships;
    final lastUsedId = orgAsync.value?.id;
    final role = ref.watch(currentUserRoleProvider).value;
    final isAdmin = role?.isAdmin ?? false;
    final selectingId = useState<String?>(null);

    Future<void> enterOrganization(String organizationId) async {
      if (selectingId.value != null) return;
      selectingId.value = organizationId;
      try {
        // Select before confirm so router refresh cannot homePathFor the
        // previous (persisted) org while this page is still mounted.
        await ref
            .read(currentOrganizationControllerProvider.notifier)
            .selectOrganization(organizationId);
        ref.read(organizationSelectionConfirmedProvider.notifier).confirm();
        // Drop stale deep links that may still point at another org.
        ref.read(pendingRedirectProvider.notifier).clear();
        if (!context.mounted) return;

        final selected =
            ref.read(currentOrganizationControllerProvider).value;
        final slug = selected?.slug;
        if (slug == null || slug.isEmpty) return;
        context.go('/$slug/$allBranchesSlug${DashboardRoute.path}');
      } finally {
        if (context.mounted) selectingId.value = null;
      }
    }

    return Scaffold(
      backgroundColor: _kInk,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Assets.icons.appIconTransparent.image(
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.organizations.selectTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.organizations.selectSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.62),
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: orgAsync.isLoading && memberships.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: _kBrandTeal,
                            ),
                          )
                        : ListView.separated(
                            itemCount: memberships.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final membership = memberships[index];
                              final orgId = membership.organizationId;
                              final name = membership.organizationName;
                              final roleName = membership.roleName;
                              final isLastUsed = orgId == lastUsedId;
                              final isBusy = selectingId.value == orgId;

                              return _OrgTile(
                                key: ValueKey(orgId),
                                name: name,
                                roleName: roleName,
                                isLastUsed: isLastUsed,
                                isBusy: isBusy,
                                enabled: selectingId.value == null,
                                reduceMotion: reduceMotion,
                                index: index,
                                onTap: () => enterOrganization(orgId),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (isAdmin)
                    OutlinedButton.icon(
                      onPressed: selectingId.value != null
                          ? null
                          : () => const SuperAdminRoute().go(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kBrandTeal,
                        side: BorderSide(
                          color: _kBrandTeal.withValues(alpha: 0.5),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: Text(t.organizations.superAdmin),
                    ),
                  TextButton(
                    onPressed: selectingId.value != null
                        ? null
                        : () =>
                            ref.read(authControllerProvider.notifier).logout(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          scheme.onSurface.withValues(alpha: 0.7),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(t.auth.logoutButton),
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

class _OrgTile extends StatelessWidget {
  const _OrgTile({
    super.key,
    required this.name,
    required this.roleName,
    required this.isLastUsed,
    required this.isBusy,
    required this.enabled,
    required this.reduceMotion,
    required this.index,
    required this.onTap,
  });

  final String name;
  final String roleName;
  final bool isLastUsed;
  final bool isBusy;
  final bool enabled;
  final bool reduceMotion;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final tile = Material(
      color: _kSurface.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLastUsed
              ? _kBrandTeal.withValues(alpha: 0.55)
              : _kSurfaceBorder,
          width: isLastUsed ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        focusColor: _kBrandTeal.withValues(alpha: 0.12),
        child: Semantics(
          button: true,
          label: '$name, $roleName',
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kBrandTeal.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: _kBrandTeal,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${t.organizations.yourRole}: $roleName',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        if (isLastUsed) ...[
                          const SizedBox(height: 6),
                          Text(
                            t.organizations.lastUsed,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _kBrandTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isBusy)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _kBrandTeal,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (reduceMotion) return tile;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index * 40).clamp(0, 160)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: tile,
    );
  }
}
