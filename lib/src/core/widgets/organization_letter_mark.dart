import 'package:flutter/material.dart';

/// Circular organization letter-mark (orgs have no image logo field yet).
class OrganizationLetterMark extends StatelessWidget {
  const OrganizationLetterMark({
    super.key,
    required this.name,
    this.size = 96,
    this.breathe = false,
  });

  final String? name;
  final double size;

  /// Soft scale pulse used on the org/branch switch overlay.
  final bool breathe;

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initials = initialsFor(name);
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials.isEmpty
          ? Icon(
              Icons.apartment_rounded,
              size: size * 0.46,
              color: colors.onPrimaryContainer,
            )
          : Text(
              initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                height: 1,
                fontSize: size * 0.36,
              ),
            ),
    );

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!breathe || reduceMotion) {
      return ExcludeSemantics(child: badge);
    }
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
