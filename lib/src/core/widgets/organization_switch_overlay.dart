import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../i18n/strings.g.dart';
import 'organization_letter_mark.dart';

/// Full-screen, opaque loader shown while switching org or branch.
///
/// Uses a stable Material progress indicator and an organization letter-mark
/// (orgs have no image logo field yet) so the wait reads as purposeful.
class OrganizationSwitchLoadingOverlay extends ConsumerWidget {
  const OrganizationSwitchLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = ref.watch(organizationSwitchOverlayProvider);
    if (!overlay.active) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = Translations.of(context);
    final name = overlay.targetName;
    final message = (name != null && name.isNotEmpty)
        ? t.navigation.switchingToBranch(name: name)
        : t.navigation.switchingBranch;

    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: colors.surface,
          child: SafeArea(
            child: Semantics(
              liveRegion: true,
              label: message,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OrganizationLetterMark(
                        name: overlay.organizationLabel,
                        size: 96,
                        breathe: true,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
