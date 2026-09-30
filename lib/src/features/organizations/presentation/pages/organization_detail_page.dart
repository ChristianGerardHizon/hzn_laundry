import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/organization_letter_mark.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';
import '../../../subscriptions/presentation/controllers/billing_access.dart';
import '../controllers/current_organization_controller.dart';
import '../widgets/tabs/organization_features_tab.dart';
import '../widgets/tabs/organization_overview_tab.dart';
import '../widgets/tabs/organization_subscription_tab.dart';

class OrganizationDetailPage extends HookConsumerWidget {
  const OrganizationDetailPage({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isTablet = Breakpoints.isMultiColumnOrLarger(context);
    // Subscription tab (package, Pay button, payment history) is billing-admin
    // only; the server enforces the same rule.
    final showSubscriptionTab = canManageOrgBilling(ref, organizationId);
    final tabController = useTabController(
      initialLength: showSubscriptionTab ? 3 : 2,
      keys: [showSubscriptionTab],
    );
    final orgAsync = useState<AsyncValue<Organization>>(const AsyncLoading());
    final isRefreshing = useState(false);

    Future<void> load() async {
      orgAsync.value = const AsyncLoading();
      final result =
          await ref.read(organizationRepositoryProvider).get(organizationId);
      orgAsync.value = result.fold(
        (f) => AsyncError(f, StackTrace.current),
        AsyncData.new,
      );
    }

    useEffect(() {
      load();
      return null;
    }, [organizationId]);

    return orgAsync.value.when(
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text(t.organizations.title),
          automaticallyImplyLeading: !isTablet,
        ),
        body: ErrorState.fromError(e),
      ),
      data: (org) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                OrganizationLetterMark(
                  name: org.name,
                  logoUrl: org.logoUrl,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    org.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: isRefreshing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: t.organizations.refreshing,
                onPressed: isRefreshing.value
                    ? null
                    : () async {
                        isRefreshing.value = true;
                        try {
                          await load();
                          await ref
                              .read(
                                currentOrganizationControllerProvider.notifier,
                              )
                              .refresh();
                          if (context.mounted) {
                            showInfoSnackBar(
                              context,
                              message: t.organizations.refreshing,
                              duration: const Duration(seconds: 1),
                            );
                          }
                        } finally {
                          isRefreshing.value = false;
                        }
                      },
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: [
                Tab(text: t.organizations.overviewTab),
                Tab(text: t.organizations.featuresTab),
                if (showSubscriptionTab)
                  Tab(text: t.subscriptions.subscriptionTab),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              OrganizationOverviewTab(
                organization: org,
                onSaved: load,
              ),
              OrganizationFeaturesTab(organizationId: org.id),
              if (showSubscriptionTab)
                OrganizationSubscriptionTab(organizationId: org.id),
            ],
          ),
        );
      },
    );
  }
}
