import 'package:flutter/material.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../subscriptions/domain/subscription_status.dart';
import '../super_admin_theme.dart';

/// Label, colour and icon for an organization subscription status.
class OrgStatusStyle {
  const OrgStatusStyle({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  /// Resolves the style for a raw `subscriptionStatus` value (null = none).
  factory OrgStatusStyle.from(Translations t, String? status) {
    final parsed = status == null || status.isEmpty
        ? null
        : SubscriptionStatus.fromString(status);
    return switch (parsed) {
      SubscriptionStatus.active => OrgStatusStyle(
          label: t.subscriptions.statusActive,
          color: kSuperAdminBrandTeal,
          icon: Icons.check_circle_outline,
        ),
      SubscriptionStatus.grace => OrgStatusStyle(
          label: t.subscriptions.statusGrace,
          color: kSuperAdminWarning,
          icon: Icons.schedule,
        ),
      SubscriptionStatus.locked => OrgStatusStyle(
          label: t.subscriptions.statusLocked,
          color: kSuperAdminDanger,
          icon: Icons.lock_outline,
        ),
      SubscriptionStatus.cancelled => OrgStatusStyle(
          label: t.subscriptions.statusCancelled,
          color: kSuperAdminMuted,
          icon: Icons.block,
        ),
      null => OrgStatusStyle(
          label: t.subscriptions.noSubscription,
          color: kSuperAdminMuted,
          icon: Icons.remove_circle_outline,
        ),
    };
  }
}

/// Pill showing subscription status with icon + text (not colour alone).
class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({super.key, required this.style});

  final OrgStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.color),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }
}
