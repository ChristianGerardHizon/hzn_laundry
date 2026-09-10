import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/organizations.routes.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';

/// Management Settings now points at org Features — flags are per-organization.
class EmailSettingsPanel extends HookConsumerWidget {
  const EmailSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final org = ref.watch(currentOrganizationControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.organizations.featuresMoved,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: org == null
                  ? null
                  : () => OrganizationDetailRoute(id: org.id).goScoped(context),
              icon: const Icon(Icons.tune),
              label: Text(t.organizations.openFeatures),
            ),
          ],
        ),
      ),
    );
  }
}
