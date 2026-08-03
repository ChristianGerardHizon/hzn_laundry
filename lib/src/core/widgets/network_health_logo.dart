import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../assets/assets.gen.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';

/// App logo with a circular border colored by PocketBase network health.
///
/// - Green — [PbConnectionStatus.online]
/// - Amber — [PbConnectionStatus.poor]
/// - Red — [PbConnectionStatus.offline] (or while checking / on error)
class NetworkHealthLogo extends ConsumerWidget {
  const NetworkHealthLogo({
    super.key,
    this.size = 40,
    this.borderWidth = 2.5,
  });

  /// Diameter of the logo image (border is drawn outside this).
  final double size;

  /// Thickness of the circular health border.
  final double borderWidth;

  static Color colorFor(PbConnectionStatus? status) {
    switch (status) {
      case PbConnectionStatus.online:
        return Colors.green;
      case PbConnectionStatus.poor:
        return Colors.amber.shade700;
      case PbConnectionStatus.offline:
      case null:
        return Colors.red;
    }
  }

  static String labelFor(PbConnectionStatus? status) {
    switch (status) {
      case PbConnectionStatus.online:
        return 'Connected';
      case PbConnectionStatus.poor:
        return 'Poor connection';
      case PbConnectionStatus.offline:
      case null:
        return 'No connection';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(pbConnectivityProvider);
    final status = connectivityAsync.when(
      data: (snapshot) => snapshot.status,
      loading: () => null,
      error: (_, __) => PbConnectionStatus.offline,
    );
    final borderColor = colorFor(status);

    return Tooltip(
      message: labelFor(status),
      child: Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: ClipOval(
          child: Assets.icons.appIconTransparent.image(
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
