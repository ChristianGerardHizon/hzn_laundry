import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';
import '../packages/pocketbase/pocketbase_provider.dart';
import 'network_health_logo.dart';
import 'organization_letter_mark.dart';

/// Org branding for nav chrome: letter-mark (health border) + organization name.
///
/// Organizations do not have an image logo field yet; initials match the
/// switch-overlay mark. Falls back to [NetworkHealthLogo] + [appTitle] when
/// no organization is selected.
class OrganizationNavBrand extends ConsumerWidget {
  const OrganizationNavBrand({
    super.key,
    this.logoSize = 32,
    this.showLabel = true,
    this.showServerUrl = true,
    this.compact = false,
  });

  /// Diameter of the letter-mark (border is drawn outside this).
  final double logoSize;

  /// When false, only the mark is shown (collapsed rail / nav).
  final bool showLabel;

  /// When true and [showLabel], shows PocketBase URL under the name.
  final bool showServerUrl;

  /// Tighter typography for drawer / dense headers.
  final bool compact;

  static String initialsFor(String? name) =>
      OrganizationLetterMark.initialsFor(name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;
    final orgName = org?.name.trim();
    final hasOrg = orgName != null && orgName.isNotEmpty;

    if (!hasOrg) {
      if (!showLabel) {
        return NetworkHealthLogo(size: logoSize);
      }
      return Row(
        children: [
          NetworkHealthLogo(size: logoSize),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 16 : 20,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.15,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showServerUrl) ...[
                  const SizedBox(height: 2),
                  Tooltip(
                    message: pocketbaseUrl,
                    child: Text(
                      pocketbaseUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final mark = _OrganizationHealthMark(
      name: orgName,
      size: logoSize,
    );

    if (!showLabel) return mark;

    return Row(
      children: [
        mark,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                orgName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: compact ? 16 : 20,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.15,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showServerUrl) ...[
                const SizedBox(height: 2),
                Tooltip(
                  message: pocketbaseUrl,
                  child: Text(
                    pocketbaseUrl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Org initials in a circle with the same network-health border as
/// [NetworkHealthLogo].
class _OrganizationHealthMark extends ConsumerWidget {
  const _OrganizationHealthMark({
    required this.name,
    required this.size,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final connectivityAsync = ref.watch(pbConnectivityProvider);
    final status = connectivityAsync.when(
      data: (snapshot) => snapshot.status,
      loading: () => null,
      error: (_, __) => PbConnectionStatus.offline,
    );
    const borderWidth = 2.5;
    final borderColor = NetworkHealthLogo.colorFor(status);
    final initials = OrganizationNavBrand.initialsFor(name);

    return Tooltip(
      message: NetworkHealthLogo.labelFor(status),
      child: Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        padding: const EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: initials.isEmpty
              ? Icon(
                  Icons.apartment_rounded,
                  size: size * 0.5,
                  color: colors.onPrimaryContainer,
                )
              : Text(
                  initials,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.36,
                    height: 1,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
