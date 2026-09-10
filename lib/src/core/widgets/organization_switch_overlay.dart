import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../i18n/strings.g.dart';

/// Full-screen, non-dismissible loader shown while switching organizations.
class OrganizationSwitchLoadingOverlay extends ConsumerWidget {
  const OrganizationSwitchLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = ref.watch(organizationSwitchOverlayProvider);
    if (!overlay.active) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final t = Translations.of(context);
    final name = overlay.organizationName;
    final message = (name != null && name.isNotEmpty)
        ? t.organizations.switchingToOrganization(name: name)
        : t.organizations.switchingOrganization;

    return Positioned.fill(
      child: AbsorbPointer(
        child: Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: theme.colorScheme.scrim.withValues(alpha: 0.6),
            ),
            Center(
              child: Semantics(
                liveRegion: true,
                label: message,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
