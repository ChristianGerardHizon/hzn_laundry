import 'package:flutter/material.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/auth.routes.dart';
import '../../../../core/routing/routes/dashboard.routes.dart';

/// Shown when the signed-in user is not a billing admin of the organization
/// (no retry: permissions do not change by retrying).
class NoBillingAccessState extends StatelessWidget {
  const NoBillingAccessState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.subscriptions.noBillingAccessTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.subscriptions.noBillingAccess,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  try {
                    const DashboardRoute().goScoped(context);
                  } catch (_) {
                    // Scope not resolved yet: splash routes to the right home.
                    const SplashRoute().go(context);
                  }
                },
                child: Text(t.subscriptions.backToApp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
