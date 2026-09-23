import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';
import '../controllers/current_organization_controller.dart';
import '../widgets/tabs/organization_features_tab.dart';
import '../widgets/tabs/organization_overview_tab.dart';
import '../widgets/tabs/organization_people_tab.dart';

class OrganizationDetailPage extends HookConsumerWidget {
  const OrganizationDetailPage({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isTablet = Breakpoints.isMultiColumnOrLarger(context);
    final tabController = useTabController(initialLength: 3);
    final orgAsync = useState<AsyncValue<Organization>>(const AsyncLoading());

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
            title: Text(org.name),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: t.organizations.title,
                onPressed: () async {
                  await load();
                  await ref
                      .read(currentOrganizationControllerProvider.notifier)
                      .refresh();
                  if (context.mounted) {
                    showInfoSnackBar(
                      context,
                      message: 'Refreshing...',
                      duration: const Duration(seconds: 1),
                    );
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: [
                Tab(text: t.organizations.overviewTab),
                Tab(text: t.organizations.peopleTab),
                Tab(text: t.organizations.featuresTab),
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
              OrganizationPeopleTab(organizationId: org.id),
              OrganizationFeaturesTab(organizationId: org.id),
            ],
          ),
        );
      },
    );
  }
}
