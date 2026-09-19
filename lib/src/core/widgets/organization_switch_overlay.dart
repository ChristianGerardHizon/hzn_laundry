import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../i18n/strings.g.dart';

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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

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
                      _OrgMarkBadge(
                        organizationLabel: overlay.organizationLabel,
                        colors: colors,
                        textTheme: theme.textTheme,
                        reduceMotion: reduceMotion,
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

/// Circular org letter-mark (fallback when no logo image exists).
class _OrgMarkBadge extends StatelessWidget {
  const _OrgMarkBadge({
    required this.organizationLabel,
    required this.colors,
    required this.textTheme,
    required this.reduceMotion,
  });

  final String? organizationLabel;
  final ColorScheme colors;
  final TextTheme textTheme;
  final bool reduceMotion;

  static String initialsFor(String? name) {
    if (name == null) return '';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsFor(organizationLabel);
    final badge = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials.isEmpty
          ? Icon(
              Icons.apartment_rounded,
              size: 44,
              color: colors.onPrimaryContainer,
            )
          : Text(
              initials,
              style: textTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
    );

    if (reduceMotion) return ExcludeSemantics(child: badge);
    return ExcludeSemantics(child: _BreathingBadge(child: badge));
  }
}

class _BreathingBadge extends StatefulWidget {
  const _BreathingBadge({required this.child});

  final Widget child;

  @override
  State<_BreathingBadge> createState() => _BreathingBadgeState();
}

class _BreathingBadgeState extends State<_BreathingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(begin: 0.96, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
