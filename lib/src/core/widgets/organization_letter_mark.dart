import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Warms disk/memory cache so the next logo paint can skip network + fade.
Future<void> precacheOrganizationLogo(
  BuildContext context,
  String? logoUrl,
) async {
  if (logoUrl == null || logoUrl.isEmpty) return;
  try {
    await precacheImage(CachedNetworkImageProvider(logoUrl), context);
  } catch (_) {
    // Ignore — callers fall back to initials / errorWidget.
  }
}

/// Org logo with zero fade so cache hits paint immediately.
Widget organizationLogoImage({
  required String imageUrl,
  required double size,
  required Widget Function(BuildContext context, String url) placeholder,
  required Widget Function(BuildContext context, String url, Object error)
      errorWidget,
}) {
  final pixelSize = (size * 3).clamp(48, 512).round();
  return CachedNetworkImage(
    imageUrl: imageUrl,
    width: size,
    height: size,
    fit: BoxFit.cover,
    fadeInDuration: Duration.zero,
    fadeOutDuration: Duration.zero,
    placeholderFadeInDuration: Duration.zero,
    memCacheWidth: pixelSize,
    memCacheHeight: pixelSize,
    placeholder: placeholder,
    errorWidget: errorWidget,
  );
}

/// Circular organization mark: logo when available, otherwise letter initials.
class OrganizationLetterMark extends StatefulWidget {
  const OrganizationLetterMark({
    super.key,
    required this.name,
    this.logoUrl,
    this.size = 96,
    this.breathe = false,
  });

  final String? name;

  /// Absolute URL for the org logo. When null/empty, shows initials.
  final String? logoUrl;
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
  State<OrganizationLetterMark> createState() => _OrganizationLetterMarkState();
}

class _OrganizationLetterMarkState extends State<OrganizationLetterMark> {
  String? _prefetchedUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchIfNeeded();
  }

  @override
  void didUpdateWidget(covariant OrganizationLetterMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoUrl != widget.logoUrl) {
      _prefetchIfNeeded();
    }
  }

  void _prefetchIfNeeded() {
    final url = widget.logoUrl;
    if (url == null || url.isEmpty || url == _prefetchedUrl) return;
    _prefetchedUrl = url;
    precacheOrganizationLogo(context, url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initials = OrganizationLetterMark.initialsFor(widget.name);
    final hasLogo = widget.logoUrl != null && widget.logoUrl!.isNotEmpty;
    final size = widget.size;

    final Widget badge;
    if (hasLogo) {
      final fallback = _InitialsBadge(
        size: size,
        initials: initials,
        colors: colors,
        theme: theme,
      );
      badge = ClipOval(
        child: organizationLogoImage(
          imageUrl: widget.logoUrl!,
          size: size,
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      );
    } else {
      badge = _InitialsBadge(
        size: size,
        initials: initials,
        colors: colors,
        theme: theme,
      );
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!widget.breathe || reduceMotion) {
      return ExcludeSemantics(child: badge);
    }
    return ExcludeSemantics(child: _BreathingBadge(child: badge));
  }
}

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({
    required this.size,
    required this.initials,
    required this.colors,
    required this.theme,
  });

  final double size;
  final String initials;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
